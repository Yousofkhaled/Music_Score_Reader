function [ segmented_img , lines] = segment( input_img)
   
    %Threshholding  
    gray_img = rgb2gray(input_img);
    bw_img = im2bw(gray_img,0.54);
    bw_img = ~bw_img;
    %figure,imshow(bw_img);
    
    %Remove horizontal lines
    mask1 = strel('line',20,0);
    eroded_img = imopen(bw_img, mask1); 
    cut_img = bw_img - (eroded_img);
    %figure,imshow(cut_img);
    
    %Remove vertical lines 
    mask4 = strel('line',38,90);
    eroded_img2 = imopen(bw_img,mask4);
    cut_img = cut_img - (eroded_img2);
    %figure,imshow( cut_img);   
    
    %Closing vertical gaps
    mask2 = strel('line',3,90);
    closed_img = imclose(cut_img,mask2);
    %figure,imshow(closed_img);
    
    %Closing curved gaps 
    mask2 = strel('line',3,45);
    closed_img = imclose(closed_img,mask2);
    img_copy = closed_img; 
    %figure,imshow(img_copy);
       
    %Closing to remove left shapes 
    mask2 = strel('rectangle',[15,4]);
    closed_img = imclose(closed_img,mask2);
    %figure,imshow(closed_img);   
    
    closed_img(closed_img < 0) = 0;
    
    [L ,~] = bwlabel(closed_img);
    [H,W] = size(closed_img);
    
    %Remove shapes with large area
    A = regionprops(L,'Area');   
    for i = 1:H
        for j = 1:W
            if( L(i,j) > 0 && A(L(i,j)).Area > 140 )
                L(i,j) = 0;     
            end 
            if( L(i,j) > 0 && A(L(i,j)).Area < 20 )
                L(i,j) = 0;     
            end 
        end
    end
    
    %Return the missing holes of notes after closing 
    for i = 1:H
        for j = 1:W
            if( L(i,j) ~= 255  && img_copy(i,j) == 0)
                L(i,j) = 0;
            end
        end
    end
    
    
    segmented_img = label2rgb(L);
    
    %Return horizontal lines (Levels)
    lines = uint8(ones (size(L)));
    lines (:, : ) = 255;
    [r, ~] = size (L);
    for i = 1:H
        for j = 1:W
            if(eroded_img(i,j) > 0)
                lines(i, j) = 0;
            end
        end
    end

    lines (1 : 10, : ) = 255;
    lines (r - 10 : r, : ) = 255;

end