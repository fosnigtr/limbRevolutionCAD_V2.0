function [x, y, z, idxLandmark] = getCord(hObject)
 % GET DATA
        model = guidata(hObject);
        
        % FILTER DATA USING BACKFACE CULLING
        % https://en.wikipedia.org/wiki/Back-face_culling
        N = normals(model.data,model.faces);
        BC = barycenter(model.data,model.faces);
        back_facing = sum(N.*bsxfun(@minus,BC,campos),2)<=0;
%         model.tmpLandmarks(back_facing) = 0;
%         set(model.handlePatch,'CData',model.tmpLandmarks);
%         drawnow;
        idxVerticesfrontFaces = model.faces(back_facing,:);
        idxVerticesfrontFaces = reshape(idxVerticesfrontFaces,...
            prod(size(idxVerticesfrontFaces)),1);
        windowedData = model.data(idxVerticesfrontFaces,:);
        
        % SET LANDMARKS
        t = 0:.01:1;
        tmp = get(model.axes1,'currentpoint');
        x = (tmp(2,1)-tmp(1,1)).*t+tmp(1,1);
        y = (tmp(2,2)-tmp(1,2)).*t+tmp(1,2);
        z = (tmp(2,3)-tmp(1,3)).*t+tmp(1,3);
        v = [x' y' z'];
        for idx = 1:101
            a(:,:,idx) = sqrt(sum(bsxfun(@minus,windowedData',v(idx,:)').^2));
        end
        
        a = squeeze(a);
        
        minC = min(a(:));
        idxC = find(a==minC);
        idxC = idxC(1); % choose only a point from a single face
        [idxLandmark,~] = ind2sub(size(a),idxC);
        
        % GET CARTESIAN COORDINATES
        x = windowedData(idxLandmark,1);
        y = windowedData(idxLandmark,2);
        z = windowedData(idxLandmark,3);
        
        % GET LANDMARK INDEX
        idxLandmark = idxVerticesfrontFaces(idxLandmark);
% SCRAP
% GET DATA
% model = guidata(hObject);
% 
% % SET LANDMARKS
% tmp = get(model.axes1,'currentpoint');
% t = 0:.01:1;
% x = (tmp(2,1)-tmp(1,1)).*t+tmp(1,1);
% y = (tmp(2,2)-tmp(1,2)).*t+tmp(1,2);
% z = (tmp(2,3)-tmp(1,3)).*t+tmp(1,3);
% v = [x' y' z'];
% 
% % lastM = 1e6;
% % for idx = 1:101
% %         [m, loc] = min(sum(abs(bsxfun(@minus,model.data',v(idx,:)')),1));
% %     if m < lastM
% %         lastM = m;
% %           idxLandMark = loc;
% %     end
% % end
% for idx = 1:101
%     a(:,:,idx) = sqrt(sum(bsxfun(@minus,model.data',v(idx,:)').^2));
% end
% 
% a = squeeze(a);
% 
% minC = min(a(:));
% idxC = find(a==minC);
% [idxLandmark,~] = ind2sub(size(a),idxC);
% 
% % GET CARTESIAN COORDINATES
% x = model.data(idxLandmark,1);
% y = model.data(idxLandmark,2);
% z = model.data(idxLandmark,3);
end

