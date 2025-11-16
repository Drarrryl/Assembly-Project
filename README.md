\documentclass{article}

%% Page Margins %%
\usepackage{geometry}
\geometry{
    top = 0.75in,
    bottom = 0.75in,
    right = 0.75in,
    left = 0.75in,
}

\usepackage{amsmath}
\usepackage{graphicx}
\usepackage{parskip}

\title{Assembly Project: Dr Mario}

% TODO: Enter your name
\author{Darryl Lubin & Yujin Kim}

\begin{document}
\maketitle

\section{Instruction and Summary}

\begin{enumerate}

    \item Which milestones were implemented? 
    \\ Milestones #1, #2, and #3 are fully implemented.
    \\ Milestone #4 has been started with 3 easy feature implemented.

    \item How to view the game:
    % TODO: specify the pixels/unit, width and height of 
    %       your game, etc.  NOTE: list these details in
    %       the header of your columns.asm file too!
    \\ Unit width in pixels:       8
    \\ Unit height in pixels:      8
    \\ Display width in pixels:    256
    \\ Display height in pixels:   256

\item Game Summary:
% TODO: Tell us a little about your game.
\begin{itemize}
\item You start with a 3 block column and as your column falls your goal is to match as many same block colors together to improve your score.
\item You are allowed to shift thee colors in your column by hitting 'w', you can move left and right by hitting 'a' and 'd', and you can move down faster by hitting 's'.
\item Once there is a column that hits the ceiling of the playing field, or if the column-generating space is occupied then the game is over!
\end{itemize}

    
\end{enumerate}

\section{Attribution Table}
% TODO: If you worked in partners, tell us who was 
%       responsible for which features. Some reweighting 
%       might be possible in cases where one group member
%       deserves extra credit for the work they put in.

\begin{center}
\begin{tabular}{|| c | c ||}
\hline
 Darryl Lubin (1009115191) &  Yujin Kim (1009852633) \\ 
 \hline
 Milestone 1 & Milestone 3\\
 \hline
 Milestone 2 & Side Panel\\
 \hline
 Pause Feature & Task\\ 
 \hline
 Basic Gravity & Task\\ 
 \hline
 Task & Task\\
 \hline
 Task & Task\\  
 \hline
\end{tabular}
\end{center}

\\ Darryl's Future tasks:
\\ Easy: 2, 9, 8
\\ Hard: 1, 4, 6 (maybe)

\\

\\ Yujin's Future tasks:
\\ Easy: 4, 5, 7, 11 (maybe)
\\ Hard: 3, 5

% TODO: Fill out the remainder of the document as you see 
%       fit, including as much detail as you think 
%       necessary to better understand your code. 
%       You can add extra sections and subsections to 
%       help us understand why you deserve marks for 
%       features that were more challenging than they
%       might initially seem.

    \begin{figure}[ht!]
        \centering
        \includegraphics[width=0.65\textwidth]{Milestone1Capture.png}
        \caption{A static image of milestone 1}
        \label{f:milestone1}
    \end{figure}
    
    \begin{figure}[ht!]
        \centering
        \includegraphics[width=0.65\textwidth]{CurrentCapture.png}
        \caption{A static image of the current game}
        \label{f:milestone1}
    \end{figure}



\end{document}
