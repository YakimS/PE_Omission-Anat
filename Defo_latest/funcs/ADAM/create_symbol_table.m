function symbol_table = create_symbol_table(n_rows, n_colu)
    symbol_table = zeros(n_rows, n_colu);
    for cond = 1:n_rows
        symbol_table(cond, :) = ((cond-1) * n_colu + 1) : (cond * n_colu);
    end
end
