function custom_colormap = create_custom_colormap(basecolor, num_shades)
   if num_shades == 1
       custom_colormap = basecolor;
   elseif num_shades == 2
       custom_colormap = [[0,0,0]; basecolor];  % Flipped order here
   else
       % Convert base color to HSV
       hsv_bc = rgb2hsv(basecolor);
       h = hsv_bc(1);
       
       % Saturation: starts high, dips in middle, ends low
       mid_point = ceil(num_shades/2);
       s1 = ones(num_shades - mid_point, 1);
       s2 = linspace(1, 0.2, mid_point)';  % Descending saturation
       s = [s1; s2];
       
       % Value: non-linear spacing with power function
        % Using power of 2 to dedicate more steps to brighter values
        t = linspace(0, 1, num_shades)';
        v = 0.02 + (0.65-0.02) * (t.^0.7); 
        v=1-v;
         % Quadratic spacing %  adjust the power (e.g., t.^1.5 or t.^2.5) to fine-tune the bias t.^2.5: even more steps in bright region, even fewer in dark
       
       hsv_colors = [repmat(h, num_shades, 1), s, v];
       custom_colormap = hsv2rgb(hsv_colors);
   end
end