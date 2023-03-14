function [] = play(level, shape)
    notes={'C' 'D' 'E' 'F' 'G' 'A' 'B'};
    freq=[261.6 293.7 329.6 349.2 392.0 440.0 493.9];
    duration = [0.25 0.5 1.0];
    %song={'C' 'C' 'G' 'G' 'A' 'A' 'G' 'F' 'F' 'E' 'E' 'D' 'D' 'C' 'G' 'G' 'F' 'F' 'E' 'E' 'D' 'G' 'G' 'F' 'F' 'E' 'E' 'D' 'C' 'C' 'G' 'G' 'A' 'A' 'G' 'F' 'F' 'E' 'E' 'D' 'D' 'C'};
    song = {};
    for i = 1 : size (level)
        song{i} = [level(i)];
    end
    %notes={} 
    a=[];
    for k=1:numel(song)
       note_value=0:0.000125:duration(shape(k)); % You can change the note duration
      a=[a sin(2*pi*freq(strcmp(notes,song{k}))*note_value)];
    end
    sound(a);
end