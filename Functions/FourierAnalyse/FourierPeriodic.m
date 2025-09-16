function [SignalSym, SignalFun] = FourierPeriodic(f_exp, t, T, N)
% [SignalSym, SignalFun] = FourierPeriodic(f_exp, t, T, N)
% Builds the N-term Fourier series (cos+sin) using [0, T] limits
% Returns:
%   SignalSym : symbolic partial sum S_N(t)
%   SignalFun : numeric function handle @(tt) evaluating S_N(tt)

    arguments
        f_exp sym
        t sym
        T (1,1) sym {mustBePositive}
        N (1,1) double {mustBeInteger, mustBeNonnegative}
    end

    omega = 2*pi/T;

    % Coefficients
    [a_of, b_of, a0] = FourierCoefficients(f_exp, t, T);

    % Symbolic partial sum
    syms k integer
    assumeAlso(k >= 1);
    seriesSum = symsum( a_of(k)*cos(k*omega*t) + b_of(k)*sin(k*omega*t), k, 1, N );
    SignalSym = simplify(a0/2 + seriesSum);

    % Numeric evaluator for plotting / arrays
    SignalFun = matlabFunction(SignalSym, 'Vars', t);

    % Clear k assumption
    assume(k, 'clear');
end
