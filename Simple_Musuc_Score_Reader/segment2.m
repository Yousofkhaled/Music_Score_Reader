function [ segmented_img , lines ] = segment2( input_img)
   
    close all;
    
    %Threshholding  
    gray_img = rgb2gray(input_img);
    bw_img = im2bw(gray_img,0.62);
    bw_img = ~bw_img;
    %figure,imshow(bw_img);
    img_copy = bw_img; 
    
    %Remove horizontal lines
    mask1 = strel('line',10,0);
    eroded_img = imopen(bw_img, mask1); 
    %figure,imshow(eroded_img);
    cut_img = bw_img - (eroded_img);
    %figure,imshow(cut_img);
       
    %Remove vertical lines 
    mask4 = strel('rectangle',[26,1]);
    eroded_img2 = imopen(bw_img,mask4);
    %figure,imshow(eroded_img2);
    cut_img = cut_img - (eroded_img2);
    %figure,imshow( cut_img);   
        
    %Closing vertical gaps
    mask2 = strel('line',3,90);
    closed_img = imclose(cut_img,mask2);
    %figure,imshow(closed_img);    

    [L ,~] = bwlabel(closed_img);
    [H,W] = size(closed_img);
    
    %Remove shapes with large area and small perimeter 
    A = regionprops(L,'Area','Perimeter');   
    for i = 1:H
        for j = 1:W
            if( L(i,j) > 0 && A(L(i,j)).Area > 140 )
                L(i,j) = 0;     
            end 
            if( L(i,j) > 0 && A(L(i,j)).Area < 29 )
                L(i,j) = 0;     
            end 
            if( L(i,j) > 0 && A(L(i,j)).Perimeter < 55 )
                L(i,j) = 0;     
            end 
        end
    end
    %figure,imshow(L);
   
    %Return the missing holes of notes after closing 
    for i = 1:H
        for j = 1:W
            if( L(i,j) > 0  && img_copy(i,j) == 0)
                L(i,j) = 0;
            end
        end
    end
    
    %figure,imshow(L);

    
    segmented_img = label2rgb(L);
    %figure,imshow(Segmented_Symbols);
    
    
    lines = uint8(ones (size(L)));
    lines (:, : ) = 255;
    [r, ~] = size (L);
    
    %Return horizontal lines (Levels)
    for i = 1:H
        for j = 1:W
            if(eroded_img(i,j) > 0)
                lines(i, j) = 0;
            end
        end
    end

    
    lines (1 : 10, : ) = 255;
    lines (r - 10 : r, : ) = 255;
    %figure,imshow(lines);
    
    
end