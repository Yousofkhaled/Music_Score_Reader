close all;
clc;

% I = imread ('TwinkleTwinkleLittleStar.bmp');
% 
% [segmented_img, lines] = segment2 (I);


I = imread ('JingleBells.bmp');
figure, imshow(I);

[segmented_img, lines] = segment (I);


% -------------------------------- part 2: Detection ------- %

bws = rgb2gray(segmented_img);
[l, w] = size(bws);
for i = 1 : l
    for j = 1 : w
        if bws(i, j) < 255
            bws(i, j) = 0;
        end
    end
end

I = bws;

figure, imshow (I);

inpict = I; % cropped from thumbnail
bpict = I<220; % pick a threshold to isolate from BG
S = regionprops(bpict,'boundingbox','filledimage', 'Area', 'Perimeter');
num = numel(S);

% important arrays

shape = zeros(num, 1);
level = char(num, 1);
sortedShape = shape;
sortedLevel = level;
note_pos = zeros(num, 2);
Indices_sorted = zeros (num, 1);
letter = ['Q', 'H', 'W']; %% whole, half, and quarter notes

C = cell(numel(S),1);
for n = 1:numel(S)
    % get mask of object only
    mk = S(n).FilledImage;
    %figure, imshow (mk);
    % get corresponding rectangular area of original image
    bb = floor(S(n).BoundingBox);

    samp = inpict(bb(2) - 4:bb(2)+bb(4)-1 + 4,bb(1) - 4:bb(1)+bb(3)-1 + 4,:);

    f1 = bb(2) - 4;
    t1 = bb(2)+bb(4)-1 + 4;
    f2 = bb(1) - 4;
    t2 = bb(1)+bb(3)-1 + 4;

    if (abs(t1 - f1) * abs(t2 - f2) < 400)
        shape(n) = 3;
        for idx = f1:t1
            I(idx, f2) = 0;
            I(idx, t2) = 0;
        end
    end

    if (shape(n) == 0)
        white_before = 0;
        white_after = 0;

        large_samp = ~samp;
        %mask = [0 1 0; 1 1 1; 0 1 0];
        mask = [0 0 1 0 0; 0 1 1 1 0; 1 1 1 1 1; 0 1 1 1 0; 0 0 1 0 0];
        closed_samp = imclose(large_samp, mask);
        %figure, imshow(large_samp);
        %figure, imshow(closed_samp);
        [r, c] = size (samp);
        for i = 1 : r
            for j = 1 : c
                if (closed_samp(i, j) > 0)
                    white_after = white_after + 1;
                end
                if (large_samp(i, j) > 0)
                    white_before = white_before + 1;
                end
            end
        end
        shape(n) = 1;

        if (((white_after - white_before) / white_after) > 0.1)
            shape(n) = 2;
        end

        if shape(n) == 1
            for idx = f2 : t2
                I(f1, idx) = 0;
            end
        end

        if shape(n) == 2
            for idx = f2 : t2
                I(t1, idx) = 0;
            end
        end
        
    end
    
    % store this image
    C{n} = samp;
end
% just plot the images for viewing
for n = 1:numel(S)
    subplot(5,10,n)
    imshow(C{n},'border','loose')
end
figure, imshow(I);


% ---------------------------  part #3 - Lines --------------------------%
%lines

[r, c] = size(lines);

col = uint32(c / 2);
before = 255;
cnt_lines = 0;

line_pos = zeros(10, 6);
set_of_lines = 0;

for row = 1 : r
    
    if ((lines(row, col) == 0))
        if (before == 255)
            cnt_lines = cnt_lines + 1;
            if (mod (cnt_lines, 5) == 1)
                set_of_lines =  set_of_lines + 1;
            end
            idx = mod(cnt_lines, 5);    
            if (idx == 0)
                idx = 5;
            end
            line_pos (set_of_lines, idx) = row;

        end
    end
    before = lines (row, col);
end

dist = line_pos(1, 5) - (line_pos (1, 4) + 1);

for i = 1 : set_of_lines
    line_pos (i, 6) = line_pos(i, 5) + dist;
    for col = 1 : c
        lines (line_pos (i, 6), col) = 0;
    end
end

figure, imshow (lines);

disp (cnt_lines);

trace = bws;

for n = 1:numel(S)

    bb = floor(S(n).BoundingBox);

    f1 = bb(2);
    lower_row = bb(2)+bb(4)-1; % lower row
    t1 = lower_row;
    f2 = bb(1);
    t2 = bb(1)+bb(3)-1; % cols -> g

    cur_lines = -1;
    mn = 100000;
    for i = 1 : set_of_lines
        if (abs(lower_row - line_pos(i, 1)) < mn)
            mn = abs(lower_row - line_pos(i, 1));
            cur_lines = i;
        end
        if (abs(lower_row - line_pos(i, 6)) < mn)
            mn = abs(lower_row - line_pos(i, 6));
            cur_lines = i;
        end
    end


    
    note_pos(n,1) = cur_lines;
    note_pos(n,2) = t2;
	% make a var named error = 3
    if (line_pos (cur_lines, 6) < lower_row)
        level(n) = 'C';
    elseif ((line_pos (cur_lines, 5) < lower_row) && ((line_pos (cur_lines, 6) - lower_row) < 3))%error
        level(n) = 'D';
    elseif ((line_pos (cur_lines, 5) < lower_row))
        level(n) = 'E';

    elseif ((line_pos (cur_lines, 4) < lower_row) && (abs(line_pos (cur_lines, 5) - lower_row) < 3) )
        level(n) = 'F';
    elseif ((line_pos (cur_lines, 4) < lower_row))
        level(n) = 'G';
        
    elseif ((line_pos (cur_lines, 3) < lower_row) && (abs(line_pos (cur_lines, 4) - lower_row) < 3) )
        level(n) = 'A';
    elseif ((line_pos (cur_lines, 3) < lower_row))
        level(n) = 'B';

    elseif ((line_pos (cur_lines, 2) < lower_row) && (abs(line_pos (cur_lines, 3) - lower_row) < 3) )
        level(n) = 'C';
    elseif ((line_pos (cur_lines, 2) < lower_row))
        level(n) = 'D';
    end
    
    shft = 0;

    trace = insertText(trace,[f2 - shft, line_pos(cur_lines, 6) + 5],level(n));
    trace = insertText(trace,[f2 + 6, line_pos(cur_lines, 1) - 30],letter(shape(n)));
    
end

[r, c] = size (lines);

for i = 1 : r
    for j = 1 : c
        if (lines (i, j) == 0)
            trace (i, j, :) = 0;
        end
    end
end

figure, imshow (trace);


temp = note_pos;
% Sorting - overrites note pos
for iterate = 1 : num
    mnr = 5000;
    mnc = 5000;
    mnID = -1;
    for i = 1 : num
        if ((note_pos(i, 1) < mnr) || ((note_pos(i, 1) == mnr) && (note_pos(i, 2) < mnc)))
            mnr = note_pos(i, 1);
            mnc = note_pos(i, 2);
            mnID = i;
        end
    end
    Indices_sorted(iterate) = mnID;
    note_pos (mnID, 1) = 6000;
    note_pos (mnID, 2) = 6000;
end
note_pos = temp;

%num = numel(S)
for i = 1:num

    sortedShape(i) = shape(Indices_sorted(i));
    sortedLevel(i) = level(Indices_sorted(i));
end

play (sortedLevel, sortedShape);
disp('lol');