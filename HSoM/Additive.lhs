%-*- mode: Latex; abbrev-mode: true; auto-fill-function: do-auto-fill -*-

%include lhs2TeX.fmt
%include myFormat.fmt

\out{
\begin{code}
-- This code was automatically generated by lhs2tex --code, from the file 
-- HSoM/Additive.lhs.  (See HSoM/MakeCode.bat.)

\end{code}
}

\chapter{Additive and Subtractive Synthesis}
\label{ch:additive}

\begin{code}
{-# LANGUAGE Arrows #-}

module Euterpea.Examples.Additive where
import Euterpea
\end{code}

There are many techniques for synthesizing sound.  In this chapter we
will discuss two of them: \emph{additive synthesis} and
\emph{subtractive synthesis}.  In practice it is rare for either of
these, or any of the ones discussed in future chapters, to be utilized
alone---a typical application may in fact employ all of them.  But it
is helpful to \emph{study} them in isolation, so that the sound
designer has a suitably rich toolbox of techniques at his or her
disposal.

\emph{Additive synthesis} is, conceptually at least, the simplest of
the many sound synthesis techniques.  Simply put, the idea is to add
signals (usually sine waves of differing amplitudes, frequencies and
phases) together to form a sound of interest.  It is based on
Fourier's theorem as discussed in the previous chapter, and indeed is
sometimes called \emph{Fourier synthesis}.  

\emph{Subtractive synthesis} is the dual of additive synthesis.  The
basic ideas is to start with a signal rich in harmonoc content, and
seletively ``remove'' signals to create a desired effect.

In understanding the difference between the two, it is helpful to
consider the following analogy to art:
\begin{itemize}
\item Additive synthesis is like painting a picture---each stroke of
  the brush, each color, each shape, each texture, and so on, adds to
  the artist's conception of the final artistic artifact.
\item In contract, subtractive synthesis is like creating a sculpture
  from stone---each stroke of the chisel takes away material that is
  unwanted, eventually revealing the artist's conception of what the
  artistic artifact should be.
\end{itemize}

Additive synthesis in the context of Euterpea will be discussed in
Section \ref{sec:additive}, and substractive synthesis in Section
\ref{sec:subtractive}.

\section{Addtive Synthesis}
\label{sec:additive}

\subsection{Preliminaries}

When doing pure additive synthesis it is often convenient to work with
a \emph{list of signal sources} whose elements are eventually summed
together to form a result.  To facilitate this, we define a few
auxiliary functions, as shown in Figure~\ref{fig:foldSF}.

|constSF s sf| simply lifts the value |s| to the signal function
level, and composes that with |sf|, thus yielding a signal source.

|foldSF f b sfs| is analogous to |foldr| for lists: it returns the
signal source |constA b| if the list is empty, and otherwise uses |f|
to combine the results, pointwise, from the right.  In other words, if
|sfs| has the form:
\begin{spec}
[sf1, sf2, ..., sfn]
\end{spec}
%% sf1 : sf2 : ... : sfn : []
then the result will be:
\begin{spec}
proc () -> do
  s1  <- sf1  -< ()
  s2  <- sf2  -< ()
  ...
  sn  <- sfn  -< ()
  outA -< f s1 (f s2 ( ... (f sn b)))
\end{spec}

\begin{figure}
\begin{spec}
constSF :: Clock c => a -> SigFun c a b -> SigFun c () b
constSF s sf = constA s >>> sf

foldSF ::  Clock c => 
           (a -> b -> b) -> b -> [SigFun c () a] -> SigFun c () b
foldSF f b sfs =
  foldr g (constA b) sfs where
    g sfa sfb =
      proc () -> do
        s1  <- sfa -< ()
        s2  <- sfb -< ()
        outA -< f s1 s2
\end{spec}
\caption{Working With Lists of Signal Sources}
\label{fig:foldSF}
\end{figure}

\syn{|constSF| and |foldSF| are actually predefined in Euterpea, but
  with slightly more general types:
\begin{spec}
constSF  :: Arrow a => b -> a b d -> a c d
foldSF   :: Arrow a => (b -> c -> c) -> c -> [a () b] -> a () c
\end{spec}
The more specific types shown in Figure \ref{fig:foldSF} reflect how
we will use the functions in this chapter.}

\subsection{Overtone Synthsis}

Perhaps the simplest form of additive synthesis is combining a sine
wave with some of its overtones to create a rich sound that is closer
in harmonic content to that of a real instrument, as discussed in
Chapter \ref{ch:signals}.  Indeed, in Chapter \ref{ch:sigfuns} we saw
several ways to do this using built-in Eutperpea signal functions.
For example, recall the function:
\begin{spec}
oscPartials ::  Clock c => 
                Table -> Double -> SigFun c (Double,Int) Double 
\end{spec}
|oscPartials tab ph| is a signal function whose pair of dynamic inputs
determines the frequency, as well as the number of harmonics of that
frequency, of the output.  So this is a ``built-in'' notion of
additive synthesis.  A problem with this approach in modelling a
conventional instrument is that the partials all have the same
strength, which does not reflect the harmonic content of most physical
instruments.

A more sophisticated approach, also described in Chapter
\ref{ch:sigfuns}, is based on various ways to build look-up tables.
In particular, this function was defined:
\begin{spec}
tableSines3 :: 
    TableSize -> [(PartialNum, PartialStrength, PhaseOffset)] -> Table
\end{spec}
Recall that |tableSines3 size triples| is a table of size |size| that
represents a sinusoidal wave and an arbitrary number of partials,
whose relationship to the fundamental frequency, amplitude, and phase
are determined by each of the triples in |triples|.

\subsection{Deviating from Pure Overtones}

Sometimes, however, these built-in functions don't achieve exactly
what we want.  In that case, we can define our own, customized notion
of additive synthesis, in whatever way we desire.  For a simple
example, traditional harmony is the simultaneous playing of more than
one note at a time, and thus an instance of additive synthesis.  More
interestingly, richer sounds can be created by using slightly
``out-of-tune'' overtones; that is, overtones that are not an exact
multiple of the fundamental frequency.  For example:
\begin{code}
-- TBD
\end{code}
This creates a kind of ``chorusing'' effect, very ``electronic'' in
nature.

Some real instruments in fact exhibit this kind of behavior, and
sometimes the degree of being ``out of tune'' is not quite fixed.
Here's a variation of the above example where the detuning varies
sinusoidally:
\begin{code}
-- TBD
\end{code}

\subsection{A Bell Sound}

Synthesizing a bell or gong sound is a good example of ``brute force''
additive synthesis.  Physically, a bell or gong can be thought of as a
bunch of concentric rings, each having a different resonant frequency
because they differ in diameter depending on the shape of the bell.
Some of the rings will be more dominant than others, but the important
thing to note is that these resonant frequencies often do not have an
integral relationship with each other, and sometimes the higher
frequencies can be quite strong, rather than rolling off significantly
as with many other instruments.  Indeed, it is sometime difficult to
say exactly what the pitch of a particular bell is (especially large
bells), so complex is its sound.  Of course, the pitch of a bell can
be controlled by mimimizing the taper of its shape (especially for
small bells), thus giving it more of a pitched sound.

In any case, a pitched instrument representing a bell sound can be
designed using additive synthesis by using the instrument's absolute
pitch to create a series of partials that are conspicuously
non-integral multiples of the fundamental.  If this sound is then
shaped by an envelope having a sharp rise time and a relatively slow,
exponentially decreasing decay, we get a decent result.  A Euterpea
program to achieve this is shown in Figure~\ref{fig:bell1}.  Note the
use of |map| to create the list of partials, and |foldSF| to add them
together.  Also note that some of the partials are expressed as
\emph{fractions} of the fundamental---i.e.\ their frequencies are less
than that of the fundamental!

\begin{figure}
\begin{code}
bell1  :: Instr (Mono AudRate)
       -- Dur -> AbsPitch -> Volume -> AudSF () Double
bell1 dur ap vol [] = 
  let  f    = apToHz ap
       v    = fromIntegral vol / 100
       d    = fromRational dur
       sfs  = map  (\p-> constA (f*p) >>> osc tab1 0) 
                   [4.07, 3.76, 3, 2.74, 2, 1.71, 1.19, 0.92, 0.56]
  in proc () -> do
       aenv  <- envExponSeg [0,1,0.001] [0.003,d-0.003] -< ()
       a1    <- foldSF (+) 0 sfs -< ()
       outA -< a1*aenv*v/9

tab1 = tableSinesN 4096 [1]

test1 = outFile "bell1.wav" 6 (bell1 6 (absPitch (C,5)) 100 []) 
\end{code}
\caption{A Bell Instrument}
\label{fig:bell1}
\end{figure}

\out{
\begin{code}
bell'1  :: Instr (Mono AudRate)
bell'1 dur ap vol [] = 
  let  f    = apToHz ap
       v    = fromIntegral vol / 100
       d    = fromRational dur
  in proc () -> do
       aenv  <- envExponSeg [0,1,0.001] [0.003,d-0.003] -< ()
       a1    <- osc tab1' 0 -< f
       outA -< a1*aenv*v

tab1' = tableSines3N 4096 [(4.07,1,0), (3.76,1,0), (3,1,0),
  (2.74,1,0), (2,1,0), (1.71,1,0), (1.19,1,0), (0.92,1,0), (0.56,1,0)]

test1' = outFile "bell'1.wav" 6 (bell'1 6 (absPitch (C,5)) 100 []) 
\end{code}
}

The reader might wonder why we don't just use one of Euterpea's table
generating functions, such as |tableSines3| discussed above, to
generate a table with all the desired partials.  The problem is, even
though the |PartialNum| argument to |tableSines3| is a |Double|, the
normal intent is that the partial numbers all be integral.  To see
why, suppose 1.5 were one of the partial numbers---then 1.5 cycles of
a sine wave would be written into the table.  But the whole point of
wavetable lookup synthesis is to repeatedly cycle through the table,
which means that this 1.5 cycle would get repeated, since the
wavetable be a periodic representation of the desired sound.  The
situation gets worse with partials such as 4.07, 3.75, 2.74, 0.56, and
so on.

In any case, we can do even better than |bell1|.  An important aspect
of a bell sound that is not captured by the program in
Figure~\ref{fig:bell1} is that the higher-frequency partials tend to
decay more quickly than the lower ones.  We can remedy this by giving
each partial its own envelope (recall Section \ref{sec:envelopes}, and
making the duration of the envelope inversely proportional to the
partial number.  Such a more sophisticated instrument is shown in
Figure~\ref{fig:bell2}.  This results in a much more pleasing and
realistic sound.

\begin{figure}
\begin{code}
bell2  :: Instr (Mono AudRate)
       -- Dur -> AbsPitch -> Volume -> AudSF () Double
bell2 dur ap vol [] = 
  let  f    = apToHz ap
       v    = fromIntegral vol / 100
       d    = fromRational dur
       sfs  = map  (mySF f d)
                   [4.07, 3.76, 3, 2.74, 2, 1.71, 1.19, 0.92, 0.56]
  in proc () -> do
       a1    <- foldSF (+) 0 sfs -< ()
       outA  -< a1*v/9

mySF f d p = proc () -> do
               s     <- osc tab1 0 <<< constA (f*p) -< ()
               aenv  <- envExponSeg [0,1,0.001] [0.003,d/p-0.003] -< ()
               outA  -< s*aenv

test2 = outFile "bell2.wav" 6 (bell2 6 (absPitch (C,5)) 100 []) 
\end{code}
\caption{A More Sophisticated Bell Instrument}
\label{fig:bell2}
\end{figure}

\vspace{.1in}\hrule

\begin{exercise}{\em
A problem with the more sophisticated bell sound in
Figure~\ref{fig:bell2} is that the duration of the resulting sound
exceeds the specified duration of the note, because some of the
partial numbers are less than one.  Fix this.}
\end{exercise}

\begin{exercise}{\em
Neither of the bell sounds shown in Figures~\ref{fig-bell1} and
\ref{fig:bell2} actually contain the fundamental frequency---i.e. a
partial number of 1.0.  Yet they contain the partials at the integer
multiples 2 and 3.  How does this affect the result?  What happens if
you add in the fundamental?}
\end{exercise}

\vspace{.1in}\hrule

\out{ ----------------------------------------------------------
sine f r = 
  proc () -> do
    a1 <- osc f1 0 -< f*r
    outA -< a1

loop :: [AudSF () Double] -> AudSF () Double
loop [] = constA 0
loop (sf:sfs) = 
  proc () -> do
    a1 <- sf       -< ()
    a2 <- loop sfs -< ()
    outA -< a1 + a2
-------------------------------------------------------------------  }

\section{Subtractive Synthesis}
\label{sec:subtractive}

As mentioned in the introduction to this chapter, subtractive
synthesis involves starting with a harmonically rich sound source, and
selectively taking away sounds to create a desired effect.  In signal
processing terms, we ``take away'' sounds using \emph{filters}.

\subsection{Filters}

Filters can be arbitrarily complex, but are characterized by a
\emph{transfer function} that captures, in the frequency domain, how
much of each frequency component of the input is transferred to the
output.  Figure \ref{fig:filter-types} shows the general transfer
function for the four most common forms of filters:
\begin{enumerate}
\item
A \emph{low-pass} filter passes low frequencies and rejects
(i.e.\ attenuates) high frequencies.
\item
A \emph{high-pass} filter passes high frequencies and rejects
(i.e.\ attenuates) low frequencies.
\item
A \emph{band-pass} (or \emph{notch}) filter passes a particular band
of frequencies while rejecting others.
\item
A \emph{band-reject} (or \emph{band-stop}) filter rejects a particular
band of frequencies, while passing others.
\end{enumerate}
It should be clear that filters can be combined in sequence or in
parallel to achieve more complex transfer functions.  For example, a
low-pass and a high-pass filter can be combined in sequence to create
a band-pass filter, and can be combined in parallel to create a
band-reject filter.

\begin{figure}
...
\caption{Transfer Functions for Four Common Filter Types}
\end{figure}

It is important to realize that not all filters of a particular type
are alike.  Two low-pass filters, for example, may, of course, have
different cutoff frequencies, but even if the cutoff frequencies are
the same, the ``steepness'' of the cutoff curves may be different (an
ideal step curve does not exist), and the other parts of the curve
might not be the same---they are never completely linear, and might
not even be monotonically increasing or decreasing.  Furthermore, all
filters have some degree of \emph{phase distortion}, which is to say
that the transferred phase angle can vary with frequency.

There is an elegant theory of filter design that can help predict and
therefore control these characteristics, but it is beyond the scope of
this textbook.  In the digital domain, filters are often described
using \emph{recurrence relations} of varying degrees.  A good book on
digital signal processing will elaborate on these issues in detail.

\subsection{Euterpea's Filters}
\label{sec:euterpea-filters}

Euterpea has a set of pre-defined filters that are adequate for most
sound synthesis applications.  They are shown in Figure
\ref{fig:euterpea-filters}.  


\begin{figure}
\begin{spec}
filterLowPass, filterHighPass :: 
  Clock p => SigFun p (Double, Double) Double

filterBandPass ::
  Clock p => Int -> Signal p (Double, Double, Double) Double

filterBandStop ::
  Clock p => Int -> SigFun p (Double, Double, Double) Double

filterLowPassBW, filterHighPassBW :: 
  Clock p => SigFun p (Double, Double) Double
\end{spec}
\end{figure}
