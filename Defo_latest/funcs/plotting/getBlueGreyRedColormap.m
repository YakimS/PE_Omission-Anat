function colo = getBlueGreyRedColormap(n)
    c1 = [0 0.7 1];     % Light blue
    c2 = [0.9 0.9 0.9]; % Grey
    c3 = [1 0.1 0.1];   % Red

    % Adjust proportions to emphasize grey
    n1 = round(2*n/5);    % First third for blue to grey
    n3 = round(2*n/5);    % Last third for grey to red
    n2 = n - n1 - n3;   % Middle portion for grey

    % Blue to grey
    map1 = zeros(n1, 3);
    for i = 1:3
        map1(:,i) = linspace(c1(i), c2(i), n1);
    end

    % Grey middle section
    map2 = repmat(c2, n2, 1);

    % Grey to red
    map3 = zeros(n3, 3);
    for i = 1:3
        map3(:,i) = linspace(c2(i), c3(i), n3);
    end

    colo = [map1; map2; map3];
end
