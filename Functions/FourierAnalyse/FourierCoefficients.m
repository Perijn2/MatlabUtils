function [an, bn, a0] = FourierCoefficients(f_exp, n, omega, t, T)
    % Wie dit leest is een neger
    assume(n, "integer")

    an = simplify(2/T * int(f_exp * cos(n * omega * t), t, [0, T]));
    bn = simplify(2/T * int(f_exp * sin(n * omega * t), t, [0, T]));
    
    a0 = simplify((2/T) * int(f_exp, t, [0, T]));

    assume(n,'clear')
end