%-*- mode: Latex; abbrev-mode: true; auto-fill-function: do-auto-fill -*-

%include lhs2TeX.fmt
%include myFormat.fmt

\out{
\begin{code}
-- This code was automatically generated by lhs2tex --code, from the file 
-- HSoM/Additive.lhs.  (See HSoM/MakeCode.bat.)

\end{code}
}

\chapter{Amplitude and Frequency Modulation}
\label{ch:AMAndFM}

To \emph{modulate} something is to change it in some way.  In signal
processing, \emph{amplitude modulation} is the process of modifying a
signal's amplitude \emph{by another signal}.  Similarly,
\emph{frequency modulation} is the process of modifying a signal's
frequency \emph{by another signal}.  These are both powerful sound
synthesis techniques that will be discussed in this chapter.

\section{Amplitude Modulation}
\label{sec:AM}

Technically speaking, whenever the amplitude of a signal is
dynamically changed, it is a form of \emph{amplitude modulation}, or
\emph{AM} for short; that is, we are modulating the amplitude of a
signal.  So, for example, shaping a signal with an envelope, as well
as adding tremolo, are both forms of AM.  In this section more
interesting forms of AM are explored, including their mathematical
basis.  To help distinguish these forms of AM from others, we define a
few terms:
\begin{itemize}
\item
The dynamically changing signal that is doing the modulation is called
the \emph{modulating signal}.
\item
The signal being modulated is sometimes called the \emph{carrier}.
\item
A \emph{unipolar signal} is one that is always either positive or negative
(usually positive).
\item
A \emph{bipolar signal} is one that takes on both positive and
negative values (that are often symmetric and thus average out to
zero over time).
\end{itemize}

So, shaping a signal using an envelope is an example of amplitude
modulation using a unipolar modulating signal whose frequency is very
low (to be precise, $\nicefrac{1}{dur}$, where |dur| is the length of
the note), and in fact only one cyctle of that signal is used.
Likewise, tremolo is an example of amplitude modulation with a
unipolar modulating signal whose frequency is a bit higher than with
envelope shaping, but still quite low (typically 2-10 Hz).  In both
cases, the modulating signal is infrasonic.

Note that a bipolar signal can be made unipolar (or the other way
around) by adding or subtracting an offset (sometimes called a ``DC
offset,'' where DC is shorthand for ``direct current'').  This is
readily seen if we try to mathematically formalize the notion of
tremolo.  Specifically, tremolo can be defined as adding an offset of
1 to an infrasonic sine wave whose frequency is $f_t$ (typically
2-10Hz), multiplying that by a ``depth'' argument $d$ (in the range 0
to 1), and using the result as the modulating signal; the carrier
frequency is $f$:

\[ (1 + d \times \sin(2\pi f_t t)) \times \sin (2\pi f t) \]

%% tremolo is the expressive variation in the loudness of a note that
%% a singer or musician employs to give a dramatic effect in a
%% performance.

Based on this equation, here is a simple tremolo envelope generator
written in Euterpea, and defined as a signal source (see
Exercise~\ref{ex:tremolo}):
\begin{code}
tremolo ::   Clock c =>
             Double -> Double -> SigFun c () Double
tremolo tfrq dep = proc () -> do
     trem  <- osc tab1 0 -< tfrq
     outA  -< 1 + dep*trem
\end{code}

|tremolo| can then be used to modulate an audible signal as follows:
\begin{code}
-- TBD
\end{code}

\subsection{AM Sound Synthesis}

But what happens when the modulating signal is audible, just like the
carrier signal?  This is where things get interesting from a sound
synthesis point of view, and can result in a rich blend of sounds.  To
understand this mathematically, recall this trigonometric identity:

\[ \sin(C) \times \sin(M) = \frac{1}{2} (\cos(C-M) - \cos(C+M)) \]

or, sticking entirely with cosines:

\[ \cos(C) \times \cos(M) = \frac{1}{2} (\cos(C-M) + \cos(C+M)) \]

These equations demonstrate that AM in a sense is just a form additive
synthesis.
%% which is why the two topics are included in the same chapter.  
Indeed, the equations imply two ways to implement AM in Euterpea: We
could directly multiply the two outputs, as specified by the left-hand
sides of the equations above, or we could add two signals as specified
by the right-hand sides of the equations.

Note the following:
\begin{enumerate}
\item
When the modulating frequency is the same as the carrier frequency,
the right-hand sides above reduce to $\nicefrac{1}{2}\cos(2C)$.  That
  is, we essentially double the frequency.
\item
Since multiplication is commutative, the following is also true:

\[ \cos(C) \times \cos(M) = \frac{1}{2} (\cos(M-C) + \cos(M+C)) \]

which is valid because $\cos(t) = \cos(-t)$.
\item
Scaling the modulating signal or carrier just scales the entire
signal, since multiplication is associative.
\end{enumerate}

Also note that adding a third modulating frequency yields the following:

\[\begin{array}{l}
\cos(C) \times \cos(M1) \times cos(M2) \\
\ \ = (0.5 \times (\cos(C-M1) \times \cos(C+M1))) \times \cos(M2) \\
\ \ = 0.5 \times (\cos(C-M1)\times \cos(M2) + \cos(C+M1) \times \cos(M2))\\
\ \ = 0.25 \times (\cos(C-M1-M2) + \cos(C-M1+M2) + \\
\ \ \ \ \ \ \ \ \cos(C+M1-M2) + \cos(C+M1+M2))
\end{array}\]

In general, combining $n$ signals using amplitude modulation results
in $2^{n-1}$ signals.  AM used in this way for sound synthesis is
sometimes called \emph{ring modulation}, because the analog circuit
(of diodes) originally used to implement this technique took the shape
of a ring.  Some nice ``bell-like'' tones can be generated with this
technique.

\ToDo{Put in an AM bell.}

\subsection{What do Tremolo and AM Radio Have in Common?}

Combining the previous two ideas, we can use a bipolar carrier in the
\emph{electromagnetic spectrum} (i.e.\ the radio spectrum) and a
unipolar modulating frequency in the \emph{audible} range, which we
can represent mathematically as:

\[ \cos(C) \times (1 + \cos(M)) = \cos(C) + 0.5 \times (\cos(C-M) +
\cos(C+M)) \]

Indeed, this is how AM radio works.  The above equation says that AM
radio results in a carrier signal plus two sidebands.  To completely
cover the audible frequency range, the modulating frequency would need
to be as much as 20kHz, thus yielding sidebands of $\pm$20kHz, thus
requiring station separation of at least 40 kHz.  Yet, note that AM
radio stations are separated by only 10kHz!  (540 kHz, 550 kHz, ...,
1600 kHz).  This is because, at the time commercial AM radio was
developed, a fidelity of 5KHz was considered ``good enough.''

Also note now that the amplitude of the modulating frequency does
matter:

\[ \cos(C) \times (1 + A \times cos(M)) = cos(C) + 0.5 \times A \times
(\cos(C-M) + \cos(C+M)) \]

$A$, called the \emph{modulation index}, controls the size of the
sidebands.  Note the similarity of this equation to that for tremolo.

\section{Frequency Modulation}
\label{sec:FM}

...
