function [ txt ] = updatecursor( empt, obj )
%UNTITLED Summary of this function goes here
% Customizes text of data tips

% pos = get(obj,'Position');
% txt = {['Time: ',num2str(pos(1))],...
% 	      ['Amplitude: ',num2str(pos(2))]};

pos = get(obj,'Position');
if length(pos) == 3
    r = sqrt(pos(1)^2+pos(2)^2);
    theta = atand(pos(2)/pos(1));
    txt = {['Radius (cm): ',num2str(r)],...
        ['Theta (degrees): ',num2str(theta)],...
        ['Height (cm): ',num2str(pos(3))]};
% elseif mod(pos(1),pi) == 0
%     txt = {['Radius (cm): ', num2str(pos(2))],...
%         ['Theta (degrees): ', num2str(pos(2)*180/pi)]};
else
    txt = {['Radius (cm): ', num2str(pos(1))],...
        ['Height (cm): ', num2str(pos(2))]};
end

end

