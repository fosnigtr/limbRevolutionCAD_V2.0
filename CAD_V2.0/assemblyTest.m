% UPDATE SCENE
% Create figure
clear all; close all;
cd('C:\Users\Tyler Fosnight\Documents\Tyler Documents\PDI\CAD');
load('innerMold.mat','model');
obj1 = model.data;
load('innerMold.mat','model');
obj2 = model.data;
obj2 = cat(2,obj2(:,1:2).*.7,obj2(:,3));
ymax = obj1(end,3) + 10;
model.data = obj2;
save('innerMold2.mat', 'model');

obj1 = reshape(obj1',1,3,size(obj1,1));
obj2 = reshape(obj2',1,3,size(obj2,1));

% INITIALIZE BUFFERS
tmpObj1 = zeros(3,size(obj1,3));
tmpObj2 = zeros(3,size(obj2,3));

% UPDATE OBJECT
tic
for idx = 0:360
    newRotationMatrix = rotz(idx);
    
    tmpObj1 = squeeze(sum(bsxfun(@times,newRotationMatrix,obj1),2));
    tmpObj2 = squeeze(sum(bsxfun(@times,newRotationMatrix,obj2),2));

    % Create plot
    figure1 = figure(1);
    set(figure1,'color',[0.192156862745098 0.188235294117647 0.188235294117647]);
    set(figure1,'position', [2590 -98  637 877]);
    
    % Create axes
    axes1 = axes('Parent',figure1,...
        'Color',[0.247058823529412 0.247058823529412 0.247058823529412],...
        'ZColor',[0 0 0],...
        'YColor',[0 0 0],...
        'XColor',[0 0 0],...
        'GridAlpha',1,...
        'GridColor',[0 0 0]);
    box(axes1,'on');
    grid(axes1,'on');
    hold(axes1,'on');
    xlim([-100,100]); ylim([0 ymax]);
    plot(axes1,tmpObj1(1,:),tmpObj1(3,:),tmpObj2(1,:),tmpObj2(3,:), 'LineWidth',2);
    pause(.0001);
    set(gca,'XTickLabel',''); set(gca,'YTickLabel','');
end
toc


