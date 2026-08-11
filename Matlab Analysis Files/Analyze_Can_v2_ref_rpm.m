clear;
clc;
close all;

%% ============================================================
%  CAN LOG ANALYZER
%  Input:
%       Idle.txt
%       RPM_naik.txt
% =============================================================

%%
idleFile = 'Idle.txt';
rpmFile  = 'RPM_naik.txt';
%%
idle = readCANLog(idleFile);
rpm  = readCANLog(rpmFile);

fprintf('Idle frames: %d\n', height(idle)); %[output:31b42fae]
fprintf('RPM frames : %d\n', height(rpm)); %[output:02183a4c]
%%

%%
%% ============================================================
% SHOW ALL CAN IDs
% =============================================================

idleIDs = unique(idle.ID);
rpmIDs  = unique(rpm.ID);

fprintf('\n===== IDLE CAN IDs =====\n'); %[output:3680c716]

for i = 1:length(idleIDs) %[output:group:4a135550]
    fprintf('0x%X\n', idleIDs(i)); %[output:1a6e58a3]
end %[output:group:4a135550]

fprintf('\n===== RPM-UP CAN IDs =====\n'); %[output:2a86e468]

for i = 1:length(rpmIDs) %[output:group:1c9d9625]
    fprintf('0x%X\n', rpmIDs(i)); %[output:63d669cf]
end %[output:group:1c9d9625]
%%
%% ============================================================
% SELECT A CAN ID TO INVESTIGATE
% ============================================================

selectedID = hex2dec('121');

idleID = idle(idle.ID == selectedID, :);
rpmID  = rpm(rpm.ID == selectedID, :);

fprintf('\nInvestigating CAN ID: 0x%X\n', selectedID); %[output:8ec5f059]
fprintf('Idle frames: %d\n', height(idleID)); %[output:1d342479]
fprintf('RPM frames : %d\n', height(rpmID)); %[output:83ec4001]
%%
%% ============================================================
% SAFETY CHECK
% ============================================================

if height(idleID) == 0
    warning('No frames for CAN ID 0x%X in Idle log.', selectedID);
end

if height(rpmID) == 0
    warning('No frames for CAN ID 0x%X in RPM-Up log.', selectedID);
end
%%
%% ============================================================
% PLOT ALL 8 BYTES - RPM UP
% ============================================================

figure; %[output:166d4c97]

for byte = 1:8

    subplot(4,2,byte); %[output:166d4c97]

    plot(rpmID.Time, rpmID.Data(:,byte), '.-');

    grid on;

    xlabel('Time [s]');
    ylabel(sprintf('Byte %d', byte));

    title(sprintf('CAN 0x%X - Byte %d', selectedID, byte));

end

sgtitle(sprintf('CAN ID 0x%X - RPM UP', selectedID)); %[output:166d4c97]
%%

%% ============================================================
% PLOT ALL 8 BYTES - IDLE
% ============================================================

figure; %[output:5ba3c854]

for byte = 1:8

    subplot(4,2,byte); %[output:5ba3c854]

    plot(idleID.Time, idleID.Data(:,byte), '.-');

    grid on;

    xlabel('Time [s]');
    ylabel(sprintf('Byte %d', byte));

    title(sprintf('CAN 0x%X - Byte %d', selectedID, byte));

end

sgtitle(sprintf('CAN ID 0x%X - IDLE', selectedID)); %[output:5ba3c854]


%%
%% ============================================================
% COMPARE IDLE VS RPM-UP
% ============================================================

figure; %[output:7c442b8c]

for byte = 1:8

    subplot(4,2,byte); %[output:7c442b8c]

    plot(idleID.Time, idleID.Data(:,byte), '.');
    hold on;

    plot(rpmID.Time, rpmID.Data(:,byte), '.');

    grid on;

    xlabel('Time [s]');
    ylabel(sprintf('Byte %d', byte));

    title(sprintf('Byte %d', byte));

    legend('Idle','RPM Up');

end

sgtitle(sprintf('Idle vs RPM-Up - CAN ID 0x%X', selectedID)); %[output:7c442b8c]
%%
fprintf('\n============================================================\n'); %[output:393f2c47]
fprintf('BYTE STATISTICS - CAN ID 0x%X\n', selectedID); %[output:1fbc2485]
fprintf('============================================================\n'); %[output:84b4ff45]

fprintf('\n');
fprintf('%8s %15s %15s %15s\n', ... %[output:group:6d94e7c4] %[output:0d87b6f4]
    'Byte', ... %[output:0d87b6f4]
    'Idle Range', ... %[output:0d87b6f4]
    'RPM-Up Range', ... %[output:0d87b6f4]
    'Idle -> RPM'); %[output:group:6d94e7c4] %[output:0d87b6f4]

fprintf('%s\n', repmat('-',1,60)); %[output:5c398b57]


for byte = 1:8 %[output:group:85daaa7a]

    if height(idleID) > 0
        idleMin = min(idleID.Data(:,byte));
        idleMax = max(idleID.Data(:,byte));
        idleRange = idleMax - idleMin;
    else
        idleRange = NaN;
    end


    if height(rpmID) > 0
        rpmMin = min(rpmID.Data(:,byte));
        rpmMax = max(rpmID.Data(:,byte));
        rpmRange = rpmMax - rpmMin;
    else
        rpmRange = NaN;
    end


    fprintf( ... %[output:8413b9c3]
        'B%-7d %15.0f %15.0f %15.0f\n', ... %[output:8413b9c3]
        byte, ... %[output:8413b9c3]
        idleRange, ... %[output:8413b9c3]
        rpmRange, ... %[output:8413b9c3]
        rpmRange - idleRange); %[output:8413b9c3]

end %[output:group:85daaa7a]


%% ============================================================
% 16-BIT SIGNAL TEST
%
% We will test adjacent byte pairs:
%
% B1:B2
% B2:B3
% B3:B4
% B4:B5
% B5:B6
% B6:B7
% B7:B8
%
% In BOTH:
%
% Little Endian
% Big Endian
% ============================================================


fprintf('\n============================================================\n'); %[output:04e4051b]
fprintf('16-BIT SIGNAL TEST\n'); %[output:5dcf0aed]
fprintf('============================================================\n'); %[output:38101ce7]


for startByte = 1:7 %[output:group:05fc0aac]

    byteA = startByte;
    byteB = startByte + 1;


    %% --------------------------------------------------------
    % Extract bytes
    % ---------------------------------------------------------

    if height(idleID) > 0

        idleA = double(idleID.Data(:,byteA));
        idleB = double(idleID.Data(:,byteB));

    end


    if height(rpmID) > 0

        rpmA = double(rpmID.Data(:,byteA));
        rpmB = double(rpmID.Data(:,byteB));

    end


    %% --------------------------------------------------------
    % LITTLE ENDIAN
    %
    % B0 + B1*256
    % ---------------------------------------------------------

    if height(idleID) > 0

        idleLE = idleA + 256*idleB;

    else

        idleLE = [];

    end


    if height(rpmID) > 0

        rpmLE = rpmA + 256*rpmB;

    else

        rpmLE = [];

    end


    %% --------------------------------------------------------
    % BIG ENDIAN
    %
    % B0*256 + B1
    % ---------------------------------------------------------

    if height(idleID) > 0

        idleBE = 256*idleA + idleB;

    else

        idleBE = [];

    end


    if height(rpmID) > 0

        rpmBE = 256*rpmA + rpmB;

    else

        rpmBE = [];

    end


    %% --------------------------------------------------------
    % Print statistics
    % ---------------------------------------------------------

    fprintf('\nB%d-B%d\n', byteA, byteB); %[output:174594fd] %[output:1f750aa8] %[output:8ebd23cf] %[output:275ae6a9] %[output:6b32377c] %[output:91f9edb6] %[output:9bea9e3c]


    if ~isempty(idleLE) && ~isempty(rpmLE)

        idleMedianLE = median(idleLE);
        rpmMedianLE  = median(rpmLE);

        ratioLE = rpmMedianLE / idleMedianLE;


        fprintf( ... %[output:81378e54] %[output:3c5986f2] %[output:3ed9d275] %[output:7594ba97] %[output:729b50b3] %[output:1ec776a1] %[output:5f21e069]
            ' Little Endian: Idle = %.1f | RPM-Up = %.1f | Ratio = %.3f\n', ... %[output:81378e54] %[output:3c5986f2] %[output:3ed9d275] %[output:7594ba97] %[output:729b50b3] %[output:1ec776a1] %[output:5f21e069]
            idleMedianLE, ... %[output:81378e54] %[output:3c5986f2] %[output:3ed9d275] %[output:7594ba97] %[output:729b50b3] %[output:1ec776a1] %[output:5f21e069]
            rpmMedianLE, ... %[output:81378e54] %[output:3c5986f2] %[output:3ed9d275] %[output:7594ba97] %[output:729b50b3] %[output:1ec776a1] %[output:5f21e069]
            ratioLE); %[output:81378e54] %[output:3c5986f2] %[output:3ed9d275] %[output:7594ba97] %[output:729b50b3] %[output:1ec776a1] %[output:5f21e069]

    end


    if ~isempty(idleBE) && ~isempty(rpmBE)

        idleMedianBE = median(idleBE);
        rpmMedianBE  = median(rpmBE);

        ratioBE = rpmMedianBE / idleMedianBE;


        fprintf( ... %[output:02c374d9] %[output:138e1a06] %[output:3bc62305] %[output:21045511] %[output:7356fb4d] %[output:6b4ebc46] %[output:3eb92419]
            ' Big Endian   : Idle = %.1f | RPM-Up = %.1f | Ratio = %.3f\n', ... %[output:02c374d9] %[output:138e1a06] %[output:3bc62305] %[output:21045511] %[output:7356fb4d] %[output:6b4ebc46] %[output:3eb92419]
            idleMedianBE, ... %[output:02c374d9] %[output:138e1a06] %[output:3bc62305] %[output:21045511] %[output:7356fb4d] %[output:6b4ebc46] %[output:3eb92419]
            rpmMedianBE, ... %[output:02c374d9] %[output:138e1a06] %[output:3bc62305] %[output:21045511] %[output:7356fb4d] %[output:6b4ebc46] %[output:3eb92419]
            ratioBE); %[output:02c374d9] %[output:138e1a06] %[output:3bc62305] %[output:21045511] %[output:7356fb4d] %[output:6b4ebc46] %[output:3eb92419]

    end

end %[output:group:05fc0aac]


%% ============================================================
% PLOT B5:B6
%
% We specifically want to investigate this pair because
% B5 and B6 showed interesting behaviour in your previous
% CAN traces.
% ============================================================


if height(idleID) > 0 && height(rpmID) > 0 %[output:group:568d3850]

    %% --------------------------------------------------------
    % Extract B5 and B6
    % ---------------------------------------------------------

    idleB5 = double(idleID.Data(:,5));
    idleB6 = double(idleID.Data(:,6));

    rpmB5 = double(rpmID.Data(:,5));
    rpmB6 = double(rpmID.Data(:,6));


    %% --------------------------------------------------------
    % Little Endian
    % ---------------------------------------------------------

    idleB5B6_LE = ...
        idleB5 + 256*idleB6;

    rpmB5B6_LE = ...
        rpmB5 + 256*rpmB6;


    %% --------------------------------------------------------
    % Big Endian
    % ---------------------------------------------------------

    idleB5B6_BE = ...
        256*idleB5 + idleB6;

    rpmB5B6_BE = ...
        256*rpmB5 + rpmB6;


    %% ========================================================
    % PLOT LITTLE ENDIAN
    % =========================================================

    figure; %[output:7dcd2510]

    plot( ... %[output:7dcd2510]
        idleID.Time, ... %[output:7dcd2510]
        idleB5B6_LE, ... %[output:7dcd2510]
        '.', ... %[output:7dcd2510]
        'DisplayName','Idle'); %[output:7dcd2510]

    hold on; %[output:7dcd2510]

    plot( ... %[output:7dcd2510]
        rpmID.Time, ... %[output:7dcd2510]
        rpmB5B6_LE, ... %[output:7dcd2510]
        '.', ... %[output:7dcd2510]
        'DisplayName','RPM Up'); %[output:7dcd2510]

    grid on; %[output:7dcd2510]

    xlabel('Time [s]'); %[output:7dcd2510]
    ylabel('Raw 16-bit value'); %[output:7dcd2510]

    title(sprintf( ... %[output:7dcd2510]
        'CAN 0x%X - B5:B6 Little Endian', ... %[output:7dcd2510]
        selectedID)); %[output:7dcd2510]

    legend('Location','best'); %[output:7dcd2510]


    %% ========================================================
    % PLOT BIG ENDIAN
    % =========================================================

    figure; %[output:21bbdbbb]

    plot( ... %[output:21bbdbbb]
        idleID.Time, ... %[output:21bbdbbb]
        idleB5B6_BE, ... %[output:21bbdbbb]
        '.', ... %[output:21bbdbbb]
        'DisplayName','Idle'); %[output:21bbdbbb]

    hold on; %[output:21bbdbbb]

    plot( ... %[output:21bbdbbb]
        rpmID.Time, ... %[output:21bbdbbb]
        rpmB5B6_BE, ... %[output:21bbdbbb]
        '.', ... %[output:21bbdbbb]
        'DisplayName','RPM Up'); %[output:21bbdbbb]

    grid on; %[output:21bbdbbb]

    xlabel('Time [s]'); %[output:21bbdbbb]
    ylabel('Raw 16-bit value'); %[output:21bbdbbb]

    title(sprintf( ... %[output:21bbdbbb]
        'CAN 0x%X - B5:B6 Big Endian', ... %[output:21bbdbbb]
        selectedID)); %[output:21bbdbbb]

    legend('Location','best'); %[output:21bbdbbb]


    %% ========================================================
    % PRINT B5:B6 RESULT
    % =========================================================

    fprintf('\n============================================================\n'); %[output:22578d05]
    fprintf('B5:B6 DETAILED RESULT\n'); %[output:161f2035]
    fprintf('CAN ID = 0x%X\n', selectedID); %[output:93ae2baa]
    fprintf('============================================================\n'); %[output:220779d6]


    fprintf('\nLittle Endian:\n'); %[output:699eae95]

    fprintf( ... %[output:9360bfa9]
        'Idle median    = %.2f\n', ... %[output:9360bfa9]
        median(idleB5B6_LE)); %[output:9360bfa9]

    fprintf( ... %[output:52803d55]
        'RPM-Up median  = %.2f\n', ... %[output:52803d55]
        median(rpmB5B6_LE)); %[output:52803d55]

    fprintf( ... %[output:332b05a2]
        'Ratio          = %.3f\n', ... %[output:332b05a2]
        median(rpmB5B6_LE) / median(idleB5B6_LE)); %[output:332b05a2]


    fprintf('\nBig Endian:\n'); %[output:317471cd]

    fprintf( ... %[output:7009b81f]
        'Idle median    = %.2f\n', ... %[output:7009b81f]
        median(idleB5B6_BE)); %[output:7009b81f]

    fprintf( ... %[output:66bfce53]
        'RPM-Up median  = %.2f\n', ... %[output:66bfce53]
        median(rpmB5B6_BE)); %[output:66bfce53]

    fprintf( ... %[output:3aae50f6]
        'Ratio          = %.3f\n', ... %[output:3aae50f6]
        median(rpmB5B6_BE) / median(idleB5B6_BE)); %[output:3aae50f6]

end %[output:group:568d3850]


%% ============================================================
% KNOWN RPM REFERENCE
% ============================================================

idleRPM = 1042;

boomRPM_low  = 1600;
boomRPM_high = 1700;


expectedRatioLow = ...
    boomRPM_low / idleRPM;

expectedRatioHigh = ...
    boomRPM_high / idleRPM;


fprintf('\n============================================================\n'); %[output:9894e9e8]
fprintf('KNOWN RPM REFERENCE\n'); %[output:1cf40bea]
fprintf('============================================================\n'); %[output:6a162676]

fprintf('Idle RPM          = %.0f RPM\n', idleRPM); %[output:8df236dd]

fprintf( ... %[output:group:4dd9a047] %[output:3f34da83]
    'Boom-up RPM       = %.0f - %.0f RPM\n', ... %[output:3f34da83]
    boomRPM_low, ... %[output:3f34da83]
    boomRPM_high); %[output:group:4dd9a047] %[output:3f34da83]

fprintf( ... %[output:group:69788291] %[output:8d745cda]
    'Expected ratio    = %.3f - %.3f\n', ... %[output:8d745cda]
    expectedRatioLow, ... %[output:8d745cda]
    expectedRatioHigh); %[output:group:69788291] %[output:8d745cda]


%% ============================================================
% FINISHED
% ============================================================

fprintf('\n============================================================\n'); %[output:7c4ac6e0]
fprintf('ANALYSIS COMPLETE\n'); %[output:8f1be3f6]
fprintf('============================================================\n'); %[output:85ff5002]


%% ============================================================
% FUNCTION: READ CAN LOG
% ============================================================

function T = readCANLog(filename)

    % ---------------------------------------------------------
    % Open file
    % ---------------------------------------------------------

    fid = fopen(filename,'r');


    if fid == -1

        error( ...
            'Cannot open file: %s', ...
            filename);

    end


    % ---------------------------------------------------------
    % Skip header
    % ---------------------------------------------------------

    fgetl(fid);


    % ---------------------------------------------------------
    % Storage
    % ---------------------------------------------------------

    ID = [];
    Time = [];
    Data = [];


    % ---------------------------------------------------------
    % Read every line
    % ---------------------------------------------------------

    while ~feof(fid)

        line = fgetl(fid);


        if ~ischar(line)
            continue;
        end


        % -----------------------------------------------------
        % Extract timestamp
        % -----------------------------------------------------

        timeToken = regexp( ...
            line, ...
            '\d+:\d+:\d+\s+\d+', ...
            'match', ...
            'once');


        % -----------------------------------------------------
        % Extract CAN ID
        % -----------------------------------------------------

        idToken = regexp( ...
            line, ...
            '0x[0-9A-Fa-f]+', ...
            'match', ...
            'once');


        % -----------------------------------------------------
        % Extract data
        % -----------------------------------------------------

        dataToken = regexp( ...
            line, ...
            '([0-9A-Fa-f]{2}(?:\s+[0-9A-Fa-f]{2})*)\s*$', ...
            'match', ...
            'once');


        % -----------------------------------------------------
        % Skip malformed lines
        % -----------------------------------------------------

        if isempty(timeToken) || ...
           isempty(idToken) || ...
           isempty(dataToken)

            continue;

        end


        % -----------------------------------------------------
        % Convert timestamp
        % -----------------------------------------------------

        timeParts = sscanf( ...
            timeToken, ...
            '%d:%d:%d %d');


        if length(timeParts) < 4
            continue;
        end


        h  = timeParts(1);
        m  = timeParts(2);
        s  = timeParts(3);
        ms = timeParts(4);


        t = ...
            h*3600 + ...
            m*60 + ...
            s + ...
            ms/1000;


        % -----------------------------------------------------
        % Convert CAN ID
        % -----------------------------------------------------

        canID = hex2dec(idToken);


        % -----------------------------------------------------
        % Convert CAN data
        % -----------------------------------------------------

        hexBytes = regexp( ...
            dataToken, ...
            '[0-9A-Fa-f]{2}', ...
            'match');


        bytes = zeros(1,8);


        for k = 1:min(length(hexBytes),8)

            bytes(k) = ...
                hex2dec(hexBytes{k});

        end


        % -----------------------------------------------------
        % Store
        % -----------------------------------------------------

        ID(end+1,1) = canID;

        Time(end+1,1) = t;

        Data(end+1,:) = bytes;

    end


    % ---------------------------------------------------------
    % Close file
    % ---------------------------------------------------------

    fclose(fid);


    % ---------------------------------------------------------
    % Check if anything was parsed
    % ---------------------------------------------------------

    if isempty(ID)

        error( ...
            ['No valid CAN frames were parsed from "%s". ' ...
             'Check the TXT file format.'], ...
            filename);

    end


    % ---------------------------------------------------------
    % Normalize time
    %
    % First frame = 0 seconds
    % ---------------------------------------------------------

    Time = Time - Time(1);


    % ---------------------------------------------------------
    % Create table
    % ---------------------------------------------------------

    T = table( ...
        ID, ...
        Time, ...
        Data);

end

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
%[output:31b42fae]
%   data: {"dataType":"text","outputData":{"text":"Idle frames: 48479\n","truncated":false}}
%---
%[output:02183a4c]
%   data: {"dataType":"text","outputData":{"text":"RPM frames : 12402\n","truncated":false}}
%---
%[output:3680c716]
%   data: {"dataType":"text","outputData":{"text":"\n===== IDLE CAN IDs =====\n","truncated":false}}
%---
%[output:1a6e58a3]
%   data: {"dataType":"text","outputData":{"text":"0x11F\n0x121\n0x21F\n0x221\n0xCFF3386\n0xCFF3387\n0xCFF3388\n0x12FF0001\n0x12FF0100\n0x12FFFF00\n0x12FFFF02\n0x12FFFF03\n0x12FFFF20\n0x13030000\n0x13030001\n0x13030002\n0x13030003\n0x13030020\n0x13030030\n0x16FF0001\n0x16FF0020\n0x16FF0100\n0x16FF0120\n0x16FF0320\n0x16FF2000\n0x16FF2001\n0x16FF2003\n0x16FFFF20\n0x18FECA00\n","truncated":false}}
%---
%[output:2a86e468]
%   data: {"dataType":"text","outputData":{"text":"\n===== RPM-UP CAN IDs =====\n","truncated":false}}
%---
%[output:63d669cf]
%   data: {"dataType":"text","outputData":{"text":"0x11F\n0x121\n0x21F\n0x221\n0xCFF3386\n0xCFF3387\n0xCFF3388\n0x12FF0001\n0x12FF0100\n0x12FFFF00\n0x12FFFF02\n0x12FFFF03\n0x12FFFF20\n0x13030000\n0x13030001\n0x13030002\n0x13030003\n0x13030020\n0x13030030\n0x16FF0001\n0x16FF0003\n0x16FF0020\n0x16FF0100\n0x16FF0120\n0x16FF0220\n0x16FF0300\n0x16FF0320\n0x16FF2000\n0x16FF2001\n0x16FF2002\n0x16FF2003\n0x16FFFF20\n0x18FECA00\n0x18FF38F0\n","truncated":false}}
%---
%[output:8ec5f059]
%   data: {"dataType":"text","outputData":{"text":"\nInvestigating CAN ID: 0x121\n","truncated":false}}
%---
%[output:1d342479]
%   data: {"dataType":"text","outputData":{"text":"Idle frames: 4204\n","truncated":false}}
%---
%[output:83ec4001]
%   data: {"dataType":"text","outputData":{"text":"RPM frames : 2179\n","truncated":false}}
%---
%[output:166d4c97]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAc0AAAEWCAYAAAAEvMzxAAAAAXNSR0IArs4c6QAAIABJREFUeF7tfQvwVsdZ\/vZi628i1oCoQxAILVRHO22DF4LRQJNfbxba0hrg104IoRoxgElguCVKCddQSEOoIqWUplpoRTGWdjqUxkDaoXFatKiTKHEIYJJqkPhXdKLjhf88m75f9tvf7jl7bt93ztnnzDAJfHt9dt999n333Xdfcfny5cuKHxEgAkSACBABIpCKwCtImqkYMQERIAJEgAgQAY0ASZMTgQgQASJABIhAIAIkzUCgmIwIEAEiQASIAEmTc4AIEAEiQASIQCACJM1AoJiMCBABIkAEiABJk3OACBABIkAEiEAgAiTNQKCYjAgQASJABIgASZNzgAgQASJABIhAIAIkzUCgYkz2f\/\/3f+rEiRPq93\/\/99Xjjz+uLl26pK666ir1vve9T918881q9OjRTlj+5V\/+Rd1+++3qr\/\/6r9VnPvMZNWXKlGHp7rvvPrV37161ZcsWNXv27GG\/P\/XUU2rBggVqyZIlas6cOc56XnzxRbVq1Sr9G8oZGBhQku+5557ryvPqV79a\/fRP\/7QaGhpSv\/zLv6zTpn0oH+3\/9Kc\/rf71X\/9V9+Ouu+5SP\/MzP6Ne8YpXpGV3\/v7v\/\/7vau3aternfu7nhvXrP\/7jP9RnP\/tZtX\/\/fvXss8+qUaNGqVtvvVVjfcUVVzjLO336tLr77rvVpk2b1KRJk3K1yZXpC1\/4glq9erWzPLRrcHBQ\/fqv\/7oaN26cTiNjcfjw4WF5RowYod7ylreoX\/3VX1W\/8Au\/oLEzx+mee+7R\/XR9mHfo\/4\/8yI+offv2efuI9u7cudObxp5PWdtbGrAsqPEIkDQbP4TVdODf\/u3f1Pr169Wf\/umfapJ5xzveoYnmL\/7iL\/Si\/oM\/+INq165davLkycMacPLkSU2aIKp3vetdauXKlfr\/zQ+kuXv3bnX11VerT37yk+r1r3991+9FSfNHf\/RH1XXXXdcpE4SPBfhv\/\/ZvdX\/uvfdedeWVV3rB+6\/\/+i+d5qtf\/aqaP3++esMb3qAOHjyovv3tb+t2T506NTPwwPT+++\/XxLh58+Yu0hQyfeyxx3R9IJnvfOc7as+ePerGG29U69atUz\/wAz\/QVScIE9heuHAhkVAyN1QpBRLatm2bWr58ud4oyfe\/\/\/u\/nTkA\/DB2EyZM6JAmMH7ve9\/btSkB9keOHFH\/\/M\/\/rOfM2972ti7SRP+Ai90\/BCv72Mc+pn7v935PjRkzphLSDG1vHgyZp50IkDTbOa6FevU\/\/\/M\/ehH73Oc+px588EH1S7\/0S12a1dmzZ9Wdd96poEHs2LGji3yQF4R47tw59aY3vUk9\/PDDWqPEwuoiTfzbvHnz1G\/\/9m+r1772tZ0kRUlz5syZmlDMD5oziO+3fuu3NKkLsbvAAvFD+\/n4xz+uF3l8IDZoX\/\/93\/+tCcVe5H2go95Tp05pbfhb3\/qWTmaT5vHjx9XSpUs13tdff32nqD\/7sz\/T7QRxyL9DS\/riF7+o23Dx4sVUQskzGdI0N7R38eLFeh4AJ9Hczp8\/r8d75MiRXdVCc\/61X\/s19eM\/\/uO63d\/97ne1JQGbJWxkkAeWAPMDyS5atEgBv3\/6p3+qhDRD2xs61nmwZp5mIUDSbNZ49aS1Tz75pLrlllvUhz\/8Yb0wukyRMMPBdInF39Q2sRguXLhQvfvd71Y33HCDLgeLPkxsNmnC9AstA2a1Bx54QOeRrwrSRNnQIEGa0Jhh7sMi7vo+8YlPKBAWNKkf\/uEf7iT58pe\/rPuMvCBR9A99+83f\/E2tTUM7AsHhj2ik0pfv+77vUytWrNBlzp07t0vThEb5la98Recxzd4gm4985CO6HjFTi+kUeMECgE1Kkukyz6RJI01ot2jXtGnT9OYkjTSBC3DDpgEECbIHaaJPjz76qHrPe94zzEQLYsY4YNOG9lRhnvWRpt1eexOQB1PmaQcCJM12jGOpvcAZHsxoWKTs3X9aRSDTNWvWaBPkT\/zET+gzRyywv\/M7v9OlkWKhh2kMhIn\/\/7u\/+7uOqQ91VEWaKBtkiAUfbTRNuNI3ECv6AK1Zzkrlt7\/5m7\/Riz00UJho0S\/ghQ3EW9\/6VvWXf\/mXmuBw3oc\/2HA8\/fTT6tChQ5pcX\/WqV+lNhU2aPlyh8aI8tANmZXwgbpAUtGnUBxNqr0lTcIApGRurNNKUzQqwwKYBWqScWT\/\/\/PP6\/Ns00YrFAhuN8ePHJ55XApM0kvedafpI025vkik\/TSb4e7sQIGm2azwL90Z22H\/+53+uPvWpT3mdfVwVycKJ\/8oCiMVsw4YNwxyChDShdYBUQSQwP4qZtkrSBNGAwOCA4nIykn7gXBTmWFPTttuFtkPLhPkObQfZfv\/3f7\/avn27Nl\/b3wsvvBBMmnLO+fd\/\/\/daA\/2xH\/uxYeVh49FL0oSpFOb5jRs3KhCnmFWTSBP9+OM\/\/mOd57bbbtN4gTyFNHFejH+Ddi6btH\/8x3\/UpllosTD1Jzn5lE2arvbaZ\/KFBY0FNBYBkmZjh66ahqdpDEm1ilnXNMdigQUh4lzQdAgySRO7+D\/8wz\/UZlMx01ZJmmllY9FctmyZmjhx4rBzUVdeEBe8fGFWhbMPiOSNb3yjE6pQ0sQ4QJvFpgParEsjRgVVkqbPexb1on9wTvrZn\/1ZvalI8kYVIGCKB3ECJxPHt7\/97dqEj9\/FixamWeCIM3M4Y1VFmi5vX1d7q5E2ltpEBEiaTRy1itsMQsN5YxZNExoqzp\/+4A\/+QGuVP\/mTP6lbKWYumBlNhyCTNHFeJE42YqaFs02RKycuRyCBDedqH\/rQh7R3cFFNE2XClIjFHeSGMnGtxXclJYQ0xXMZZAHvUVzv8JVXJWma3rPwmv3mN7+pDhw4oDVAmGXNaztCmi5vVFxRgSkbmxDR2EzSvOmmm\/TcERMtNHXgiLNkmH6xoaqKNEPbW7HIsfgGIUDSbNBg9aqpct0g6UwTpjloGrh7B01B7mZiEfJ9H\/3oRzsOQTZpIg8IU8y08KjFmWDee5pJpIkzQXh94kzTdXUk9ExTtD9cqYBm+rWvfU1rSz7TLPqYRppw\/IGGd+bMGV3Oz\/\/8zycOeyhpuu6vAiP7zFYqc50RYmP0R3\/0R\/peKIgTYyMkmNVCYWvs2FSJiRYk+xu\/8RvafI67sWnnlSHmWVzPwSYMHsrYKGVtb69kj\/XUHwGSZv3HqOctTPOexeIJwoEmIsELYE4DgYL0cIHd\/KBFytUUcQhykSbKFTMtyoHprGzSFM0XBO07J0Tbk7xnEUgAGwp4DQsWv\/u7v6vbCo0ICz7OTF3aYRJpgihBvvhAmNDM0r5ekqZo1egjHMVgav3gBz\/YZZ71OdbY\/bBJUzZd73znO9XYsWO1lUPmSghppjl32b+TNNNmFn\/3IUDS5NwYhgDMjSAGOG+47mmKxya8RWFGg4cj\/vuNb3zDeSdTTLdYbHG1Ag4\/LtJEQ8RMC20Qn32f0WxsUkSgtHua0DTFu9U1BULvaULjBsHDwxVOLiBibCRc9w6TNE14kEILwgfMEQEn5AslzZCyzDRJRCVthROUBKbISkI2acocwX1WOFDh\/iZMs\/hCSFPOzhEVCXPG9HYFIUN7B6GjvSDlrO3Nih\/TtxcBkmZ7x7ZQz7Agwgx37NixTkSg17zmNerrX\/+6jggEwpTF3efsYzZAtFcQJggWDj9Y8F0X4cVMi1B4eUnTFREI2jC8Nt\/\/\/vc7I+zYhAzHpKNHj2oN2owIJI45YpYVTRoOLsANi\/3rXvc6p5nWpWnK3U6cX4Ls7UAQaBdMwXC6sb9+kCbaIMENcE8U44kP14vyaprIL9dr8P+wZGCOhZKmaToG9mgXzLz\/8A\/\/oB555BH1n\/\/5n3ouYexNx6XQ9hYSJmZuFQIkzVYNZ7mdgSkT4c8QGQgh3eCcg7uXH\/jAB\/Q9Q4mHigUOC74vzixaZTsEQXvwkaaYPHFmmpc07diz0IZxPvgrv\/Ir+gzWjD7kQ01iwbpizyIPTMm4TgNTrh3FB1osyAROLqaZ1kWacPwB0UJT930+HPpFmhI1CmZUbIBmzJhRmDTFRItzUmCKUI2hpIl0mDcIc\/jQQw\/pzR02NdBaf\/EXf1FbFX7qp36qMxbUNMtdK2IqjaQZ02izr0SACBABIlAIAZJmIfiYmQgQASJABGJCgKQZ02izr0SACBABIlAIAZJmIfiYmQgQASJABGJCgKQZ02izr0SACBABIlAIAZJmIfiYmQgQASJABGJCgKQZ02izr0SACBABIlAIAZJmIfiYmQgQASJABGJCgKQZ02izr0SACBABIlAIAZJmIfiYmQgQASJABGJCgKQZ02izr0SACBABIlAIAZJmIfiYmQgQASJABGJCgKQZ02izr0SACBABIlAIAZJmIfiYmQgQASJABGJCgKQZ02izr0SACBABIlAIAZJmIfiYmQgQASJABGJCgKQZ02izr0SACBABIlAIAZJmIfiYmQgQASJABGJCgKQZ02izr0SACBABIlAIAZJmIfiYmQgQASJABGJCgKQZ02izr0SACBABIlAIAZJmIfiYmQgQASJABGJCgKQZ02izr0SACBABIlAIAZJmIfiYmQgQASJABGJCgKRZcLSfeuoptWDBAvXcc891Stq\/f7+aOnVqV8lf+MIX1OrVq9Wb3\/xmtXfvXjVy5MjO71LG6NGju36777771OHDh9W+ffvUpEmThrXUrNtVblrX0KadO3d2lf\/444+roaGhTtbbbrtNrVy5squoF154QS1cuFD30f4trU75HX3bvXv3sOQzZ85UW7ZsUQMDA6FFFUqHdqDP9pgUKpSZvQhQXrplKXSq9FNeXnzxRbVq1Sq9FuEbM2aMd00K7U+T05E0C4yeEMzmzZvVnDlzdElCjua\/2ZPOJlVzITHzJZGmSVxLly7VkxpfCOGY7TEFQMocN26cLgfpbHI0SdVFqKFwuvomZYeWC9yOHDmiFi9eHFptJ5309dSpU86NTOYCmSEVAcrL8A1oKmjfS9BPeZE1TdYt12Y7tB9tSEfSzDmKWbQtIcUpU6ao8+fPKyEl0aZM0jRJLIk0ZQHKOpGl3RcuXFDQbPFfnyYr5Io2QxM7evRoR1tGPmiFRTRNW4u2STtJ2xTM8rRB8mLogQE+apo5BSEwG+WlufJiD7Fr8xM4DVqRjKSZcxizTBxzp3b8+PFhJlfbZCWaVhJp2rs9k0TPnTunyc0sB6ZQEOzkyZPVunXr1Nq1a9WePXuCzL9iNgZp4rvmmmu0SToPYQncSTtnaNvjx4\/XZmKX5r1jxw61YcMGBS0Rn5imL1682GUqd5nJkR54P\/TQQ+quu+7SWMimwDSZ55wWzOZBgPLSXHmxh1RMxaZsxjTxSZo5R9s2WfiKsbW106dPDyMDIc3p06erS5cuqZMnT2rt79ChQ15Ss0nHXJRmzZqlzbUoB+bV9evXdwjUbGcSKZsmXNtcWkTLM0kz6UwT6UyTs5iKRUt\/5plnuojbblOICckeG5JmTmEIyEZ5KU6a\/ZYXDLOsMzGfa5I0AwTelSR0EbAXc9NUK+ePZprZs2drMoApd8SIEerYsWNO82kSaeJ8NcRJyEeavjNPwaEs0rTNs7ZDFDRbcVSCFmlqni6ShHYt2qX8vmTJks55sz2OJM2ckz9HNspLcdLst7yU5c+QY\/rUKgtJM+dwhJqb7MVCFmrRJuEVaxOA6Snn29ElmWfFc1fK8TnW+EjTrN9lgqmKNDEUZpvwd2wgQHxnz57t0rp9pGkPZ5JTEUkz5+TPkY3yUj5p9lJeQjbhOaZFI7OQNHMOW4hjg+01a1clhOTTRnGNxUeaaY5A9tUR1\/meizSF5NFW35lFGmmanqm+cpIIW3bUY8eO1SZanDnC8Qjat0s7hzNSqCZjjgFJM+fkz5GN8uInzbrLCz3Nuyc8STPHAiBZ0lzoxWHGXOyR1zbR2udzSCMk4CPNpCsncv6HckAoy5cv116itoeoTVymcCRpaGmkGQKpizRd3rM+ErcX4TRzratNJM2QkSovDeWlem\/zKuQlbS0qb4Y0oySSZsFxSrqs7bqziepsE62YIU1vVPNqSNbgBmJeNa+jmN600mXfuagNiR04oSzSdDk2+OpCm2wcpJ+ysRAcJdBEmncfSbPg5M+RnfJSbnCDquUlyVqWJl85pkcjspA0GzFM8TbS5TgVLxr+nieZ480zanuRNTUT3xUd4t0cBCgv1Y8VSbN6jFlDAQR82nqBIluXFVYJuXuLazMgUBAlzPG44oS7wRKEAv8uZnszHbyTV6xYobZu3eoM2dg60FraIcpL9QNL0qweY9aQAwHTLNTreLQ5mlurLGLaB1HaMZBNosSVHnglI53gPW3aNO8VnVp1ko3pQoDy0rsJ0UrSpMmpdxOINdUPAZjofFojZOPEiRPaC\/nBBx9UEyZM6JCkqYXWr1dsERGoBwKtI02anOoxsdiK\/iCQpDGaZCrXeUzNkqTZnzFjrc1CoHWkiZ10kslp4sSJzRohtraRCJw5c6bn7RbChDexHUhfHES2bdvWMdmCJJM0TcpKz4cwygr7IStFgG4daYYsBE0bpCIDnCUvFkli40csCz5Z0mYZI19aOPvccsst6vLly+qVr3xlJ5wg0ouGOWPGDH12KYSKDebnP\/\/5TuD7a6+9ViFusTxz1+s+lIFDL8sgPs2UlaJzpFWk6TJNmSankXc9WhQv5icCmRB44f4ZmdLnSYx7qTfddJO69dZb9R\/XEQUI84EHHugK3I97dgcPHlRf+tKX1BNPPKHuuOMOnebGG29UlJU8I8E8RRDohawUaZ\/kbRVpolNJmiYXgjKmDMvIgkAvFgJXwAC08Z577lFXXHGFfibO\/OSuJp6Ge\/LJJ9Vjjz2mf4bmhCfX4HFLWckyykxbBgK9kJUy2tk60kw60+RCUMaUYRlZEOjHQuDznjVlA31IcpqjrGQZZaYtA4F+yEqedreONNO8Z3kO4Z8mxCZZhLLgkyVtHsH15UnynrVJU4gTT67ZkYJE8+QZN+Ulz\/zMMv+zpM3TlrLztI40AVDSPU16BJY9hVieD4FeE06S96zIhXiW4+\/meb8rIAJlhXO7Vwj0WlaK9KuVpFkEEOYlAk1EICSij6lpukiS9zSbOPJsc68RIGn2GnHWRwRKRiCEMEM1zblz5zKMXsnjw+LahQBJs13jyd5EiIDPe9Z+tcQ+07SffUp6QzVCWNllIuBEIBrSNBcWLg4vzwWY6ZYtW6bWrFnTed3CfIw6xmDpNgmZ7wbGgg3lZfh6SVlxs2hs8hIFaZrnN\/ASXLVqleJrDkq5Hrq2TX2xnXOh\/xs3blTz58\/Xm4ikeK1txYby4ibMhQsXqgsXLnQeQ49dVoBSjPISBWli4du0aZPavn27wnuD5ksPAwMDURohZHcIDRNRYUTTtHfT5hUeYBfbZy6Mg4ODXVp5W7GhvHTPcspKuNTHIC9RkCYWtwMHDujnkECSbV3swqe23zxrL5hJz0zlqa9peUyta9SoUV2br7ZiQ3lxz1J7Q0lZ8WvkiG\/cVnmJgjRtzZKk6SdNG5u2EkMoeZsm2FiwobyEkWYs8yFUVpAuBnmJgjS5c\/ZPe+6e\/dhgAUAwdLFQxKJZUF7CSDOW+RBKmrHISxSkyTOacNLkmeZLWLmcfGLBhvISRpqxzIcQ0oxJXqIgTXoDhpMmPQLdhCmegqbnNb1nQ5bT9qSxSZKy4t9gtlleoiBNDCDvnYXtnpEqlruILkTMvpu\/y13NWLChvLidXHinuRuXGOUlGtJsz36XPSECRIAIEIF+IUDS7BfyrJcIEAEiQAQahwBJs3FDxgYTASJABIhAvxAgafYLedZLBIgAESACjUOApNm4IWODiQARIAJEoF8IkDT7hXzJ9eJC+tDQkLNUBKlftGiR2rVrl9q7d6+Ov1v2Z3pb2k9SmXVJO8eMGdMJfF12W1geEUhDgPKShhB\/9yFA0mzh3HCFCaw6dKB9IT4JVtcTSy0cBnapIQhQXhoyUDVpJkmzJgNRZjOqJkhXW0maZY4gy+olApSXXqLd\/LpIms0fw2E9SNs579mzR126dEn\/OXz4sIL5dtu2bWr58uXq1KlT+u+mGReRb3bv3q3r8T3gbZOmREtB+XY+apotnHQN7hLlpcGD14emkzT7AHrVVYYsAiCzffv2qbFjx+pHuc+fP6+JEh8e2507d66aM2dO19uj+M33gLcrXunZs2cVnggSAp03b56aOnWqjjhkR1apGhOWTwR8CFBeODeyIEDSzIJWQ9KGLALoCggNnxlD1YynOWvWLE2SQnZIa7+AIZC4SHPnzp1OZx+SZkMmUiTNpLxEMtAldZOkWRKQdSqmrEVgcHBQa50w2Zqfbb7Fb64zTbzLuHr1ap3V9JYladZptrAtlBfOgSwIkDSzoNWQtGUtAi5N0wdBmiOQ+dYetFmaZxsymSJoJuUlgkEusYskzRLBrEtRZS0C9pnmwMCANuWaDzP7zLP2s1nQOuWMk5pmXWYK2yFHDpivpvObKUNwnMOXdpxBeYljPpE0WzjOZZIm4DG9Z12mWZd51vaeNfORNFs46RrcJcpLgwevD00nafYB9DZWmWaeNftM0mzjDGCfsiBAecmCVr3SkjTrNR6NbQ0XgcYOHRveBwQoL30AvaQqSZolARl7MYw9G\/sMYP+zIEB5yYJWvdKSNOs1HmwNESACRIAI1BgBkmaNB4dNIwJEgAgQgXohQNIsOB6mmUWKcj2NJRf9fYEBFixYoEaPHj0s5quEu5s0adKwlpp1+7xak7qHNtlRe+wnk1yxZuHIg6AHCIknbvhZYTQ9cs28M2fOVFu2bFG43lLlF+IRXGX9sZZNeXkpClfWr9\/yIu2V9cEXgzprv5qYnqRZYNRkAm3evFnHacUn5Gj+m339wiZVcyEx80FQfKRpEtfSpUt1uDt8IYRjtseO1AMyHDdunC4H6WxyNEm1iOC4+pZVIIHbkSNH1OLFizONojluEvVI+lw1WWdqaMsSU15uK7TJtNeCXsmLTENz3Sgi+02f1iTNnCOYRdsSUpwyZYoOjG4v0CZpmiSWRJoiMELALq3R1TVp94ULF7Rmi\/8icLtLkxUhkWDuR48e1WHxoNUiH7TCIpqmvQhI20IITDAr0gbgY\/exige6c06xVmWjvDRfXsraMDd9YpM0c46ga9fsK0q0TxDc8ePHh2mPtslKdnFJpGmTpEmi586d0+RmloOnvVD\/5MmT1bp169TatWsVIp2EmH\/FbAzSxHfNNdcomJOLEFaSpglte\/z48WpoaEi5NO8dO3aoDRs2dGLiimn64sWLul2IWITPZSa3xyjLYp5zqjDb9wL92+NJeQmfGv2WF5ETtLjohjm81\/VMSdLMOS4mEeJsz\/fZmszp06eHkYGQ5vTp0\/UblydPntTa36FDh7ykZguRSeISMxblwLy6fv165zuYSaScZIopQ8tLO6MBnqbJWUzFooU+88wzXcRttylE8y6jHzmnT3TZKC\/FN5nypq05ecQHoGp5wfh9\/vOf15YlvLtbZMPc9MlP0sw5gqGLgL0wm6ZaOX8008yePVuTAUy5I0aMUMeOHXOaT5NIE+erIU5CPtL0nXkKVGWQjatuKdfUbMVRCVqkqam4SBLatWiX8vuSJUs6582+oU7aPOScHsxmIUB5KU6atlWoV\/IiWibe2C3DytR04SBp5hzBUPOsvVgIIYk2ibNEmwBMLcw84zSbmmSeFc1XyvEd2vvIwqzfNI9WTZoo32wT\/o4NBIgPwd7NRcNHmvZwhjgshI5lzqnCbBnMs5QX93RJklWRi6rkBXVDRhDQXo5AqGlSrDMjEHIWZnvN2pUIIfm0UZzN+UgzzRHIvjriOt9zCaL5BqaLMNGHNE1TsJF3OF3lhCwCY8eO1SZaOCLhHAXat0s7h8koVJNxDbSNZebJwAypCFBe\/JpmneXFbpvLNBybxzk1zVRx9ydIc6EXU4a52JukI\/9un88hjZCAjzSTrpzI+R\/KkTMI+w6ordVB4zUFJElDSyPNEEhdpOnynvWRuL0Ip5lrbS1dTLlwIhJiNp+GCukD02RDgPJSvbd5FfJijnIZsp9t1tQvNUmz4JgkXdZ23dlEdbaJVswqpsnDvBriuxLiO7cU86p5HcX0ppUu+85FbUjswAllCI7PEchXF9pk4yBlyMZCcBTvWZ+mLBsGcazIExii4LSJNjvlpdzgBr2SF5mwZch+0yd\/rUkzycSYFNHF3G2FXDto+iC2uf0ux6k295d9IwJFEKC8FEEvLG9tSROaltwnxIVz86FYXNvAfUfXS+pmOhxar1ixQm3dutV5eT8MIqbqJwI+bb2fbWLdRKCuCFBeqh+Z2pKm3XUxV4Io7XuRJlHiAj48LZFOzKDTpk1LvXZQPdSsIQsCphNVr+LRZmkf0xKBOiFAeendaDSGNGF28GmN2F2dOHFCe1Y++OCDasKECR2ShBkXX95wb70bCtZEBHqPAI8yeo85a2w2Ao0gzSSN0SRTuaJgapYkzWZPULa+OgR4lFEdtiy5vQjUnjSFMOEhaWuLcui9bdu2jskWJJmkaU6cOLG9o8me1QaBM2fO1KYtvoZAy0w6yqCs1H4IW9HAJsiKCXStSRPOPrfccou6fPmyeuUrX9kVgFs0zBkzZuizSyFUiZEoF+uvvfZahVis8nQXFoKmDVKvJIPYJCOdBZ8saXs1vnY9IRtMyop\/dJowxv2aW1mwyZK2X\/1pBGnirt1NN92kbr31Vv3HZUoCYT7wwANdwchxN+\/gwYPqS1\/6knriiSfUHXfcodPceOONauRdj9YBc7YhIgReuH9GLXvrOvIwjzIoK7UctlY3qq6yYoNeW03TdQkajb\/nnnvUFVdcoZ++Mj+55Ivnrp588kn12GOP6Z+xi8EzUvC45ULQapmrZefqvBAkaZqUlVpOp1Y3qs6y0ghN054dPu9Z81wGeZKcG7gRprQMAAAeaklEQVQQtFrmatm5Oi8ESWealJVaTqdWN6rOstI40kzynrVJU4gTz0i5wqM1zX7eSykhNsloZ8EnS9pejrFZV5r3bBP60C\/sxIrFM1\/3CGSZO1nS9nO8pe7ammelgUnes0hjk6Z5LuMKiECPwDpMuzja0IQFNemeJmUljnlah142QVYaQZohEX1M0nSRJO9p1kEk2AYiQASIQDsQqK2mGUKYoZomXhyXKyftGDb2gggQASJABPqBQG1J0+c9a79aYptn7Yefk96F7AfgrJMIEAEiQASai0BtSbNsSE0SJpG+jC5M2suWLVNr1qzpvARjPkYdY7B0e8NmvssZCzaUl+ErEGXFvSrHJi9RkKZ51gmP2lWrVim+fKKU66Fr2ywe25kw+r9x40Y1f\/58vYlIim3cVmwoL27CXLhwobpw4ULnMfTYZQUoxSgvUZAmFr5Nmzap7du3K7zNab6KMjAwULZS24jyZHcIDRMRlETTtHfT5rUEYBfbZy6Mg4ODXVp5W7GhvHTPcspKuNTHIC9RkCYWtwMHDuinw0CSbV3swqe23zxrL5hJT7Llqa9peUyta9SoUV2br7ZiQ3lxz1J7Q0lZ8WvkiAXeVnmJgjRtzZKk6SdNG5u2EkMoeZsm2FiwobyEkWYs8yFUVpAuBnmJgjS5c\/ZPe+6e\/dhgAcDDAWKhiEWzoLyEkWYs8yGUNGORlyhIk2c04aTJM82XsHI5+cSCDeUljDRjmQ8hpBmTvERBmvQGDCdNegS6CVM8BU3Pa3rPhiyn7UljkyRlxb\/BbLO8REGaGEDeOwvbPSNVLHcRXYiYfTd\/l7uasWBDeXE7ufBOczcuMcpLNKTZnv0ue0IEiAARIAL9QoCk2S\/kWS8RIAJEgAg0DgGSZuOGjA0mAkSACBCBfiFA0uwX8qyXCBABIkAEGocASbNxQ8YGEwEiQASIQL8QIGn2C\/mS68WF9KGhIWepCFK\/aNEitWvXLrV3714df7fsz\/S2tJ9vM+uSdo4ZM6YT+LrstrA8IpCGAOUlDSH+7kOApNnCueEKE1h16ED7QnwSrK4nllo4DOxSQxCgvDRkoGrSTJJmTQaizGZUTZCutpI0yxxBltVLBCgvvUS7+XWRNJs\/hsN6kLZz3rNnj7p06ZL+c\/jwYQXz7bZt29Ty5cvVqVOn9N9NMy4i3+zevVvX43vA2yZNiZaC8u181DRbOOka3CXKS4MHrw9NJ2n2AfSqqwxZBEBm+\/btU2PHjtWPcp8\/f14TJT48tjt37lw1Z86crrdH8ZvvAW9XvNKzZ88qPBEkBDpv3jw1depUHXHIjqxSNSYsnwj4EKC8cG5kQYCkmQWthqQNWQTQFRAaPjOGqhlPc9asWZokheyQ1n4BQyBxkebOnTudzj4kzYZMpEiaSXmJZKBL6iZJsyQg61RMWYvA4OCg1jphsjU\/23yL31xnmniXcfXq1Tqr6S1L0qzTbGFbKC+cA1kQIGlmQashactaBFyapg+CNEcg8609aLM0zzZkMkXQTMpLBINcYhdJmiWCWZeiyloE7DPNgYEBbco1H2b2mWftZ7OgdcoZJzXNuswUtkOOHDBfTec3U4bgOIcv7TiD8hLHfCJptnCcyyRNwGN6z7pMsy7zrO09a+YjabZw0jW4S5SXBg9eH5pO0uwD6G2sMs08a\/aZpNnGGcA+ZUGA8pIFrXqlJWnWazwa2xouAo0dOja8DwhQXvoAeklVkjRLAjL2Yhh7NvYZwP5nQYDykgWteqUladZrPNgaIkAEiAARqDECJM0aDw6bRgSIABEgAvVCgKRZcDxMM4sU5XoaSy76+wIDLFiwQI0ePXpYzFcJdzdp0qRhLTXr9nm1JnUPbbKj9thPJrlizcKRB0EPEBJP3PCzwmh65Jp5Z86cqbZs2aJwvaXKzwy8gHr4VFmVaL9cNuXlpShcWb9+y4vIvAQ62bx5sw6zGeNH0iww6kIw5gSSxdj8N\/v6hU2q5kJi5oOg+EjTJK6lS5fqcHf4QgjHbI8dqQdkOG7cOF0O0tnkaJKqL3h7CKSuvknZoeUCtyNHjqjFixeHVNmVBvWjvqreF83coAgyUF5uK7TJtNeCXsmLrBdYK7BJTlqXIpjGiqSZc5SzaFtCilOmTNGB0YWURJsySdMksaTJKQIjBOzSGl1dk3ZfuHBBa7b4LwK3uzRZERYJ5n706FEdFg9aLfJBKyyiadqLgLTNxsfVD8EsTxuy1JNzejCbhQDlpbnyYq81sU9ukmbOGeDaNfuKEu0TBHf8+PFh2qNtshJNK4k0bZI0J\/a5c+c0uZnl4Gkv1D958mS1bt06tXbtWoVIJyHmXzEbgzTxXXPNNQrm5DyEJRglaZrQtsePH6+GhoaUS\/PesWOH2rBhQycmrpimL168qNuFiEX4XGZy\/HuoiTDn1GA2BwKUl+bKS+iGPJaJT9LMOdImEeJsz\/fZ2trp06eHkYEs4tOnT9dvXJ48eVJrf4cOHfKSmk065qIkMWNRDsyr69evd76DmUTKpgnXNpcW0fJM0pQ3Ok3s5EwT\/2aanMVULFroM88800XcdpuSBN1ewGM3N+UUgUzZKC\/FSbNf8iJHGZA9eR\/XtyHNNCkampikmXPgQhcBezE3TbVy\/mimmT17tiYDmHJHjBihjh075jSfJpEmDuhDnIR8ZOE78xSoyiJNW8uVck3NVhyVoEWamqeLJKFdizDL70uWLEl1WMiiBeWcLtFno7wUJ81+yYs4IYnVJ\/ZNJkkz53IWutDai4UQkmiTOEu0CcD0lPN5dSaZZ0XzlXJ8jjW+yW\/W7\/KSq4o0MRRmm\/B3bCBAfAj2bi4aPtK0hzPEqSgLweacLtFno7yUT5q9khffWhOrBy1JM+dyFuLYYHvN2lXJpPNpozib85FmmiOQfXXEZU5xkaZ5FcMnFGmkGeKenkTYQo5jx47VJlo4IsHxCNq3SzuHM1KoJuMa7tAFPedUYTalFOXFT5p1lxd7rYldXkiaBZa0NBd6cZgxF3vTEUX+3T6fQxohAR9pJl05kfM\/lANCWb58+bA7oPYuFRqvKbxJGloaaYZA6iJNl1erj8TtRTjNXGu2ySZYXj8JGbHiaSgv1XubVyEvtqzRPHv58uXi4hBvCUmemK47m0DKNtGKGdL0RjWvhviuhPjOLcW8al5HMb1pZbR856L2aNqBE8oiTZdjg68utMnGQfopGwvBUbxnk8xHISbweGd1dT2nvJQb3KBX8mJuqGMPBEJNs7r1gSWXgIDLcaqEYlkEEWglApSX6oe1laRpmihCHEGqh5k15EXAp63nLY\/5iECbEaC8VD+6rSNN8xV2RNyBI8m8efN0nFR+zUHAdKLqVTza5qAzvKVJjl+mac3G0txgxnz3rsljbx75wImO8lLtaLaONHFWdf3115Mkq503LL1GCIAUJcrTyJEjdUxdyAHi6srGcdq0afq+Kv4dHxzEzHS4B7tixQq1detWZ0jFGnWXTSECfUWgVaQJ7WTjxo3q9a9\/vY6Cgy828+zIux7t64Qqo\/IX7p8RVEzRvrrqyVtmaJuDOlYwkWiWIEaETVy2bJlas2aNJkOTKBEWEfdfkU40eyHXgk1g9goRcM3RtPln50lLj+b7ZCEkr6v7SbKVt8wKYfYW3TrSdIVew6Ig5tmJEyf2A+ee1fn\/3re3Z3VVVdEPPbwwqOiifXXVk7dMu6wzZ84E9aGKRHAGEa0R5W\/atElt375dQQs1f0OYxgkTJnQiJplaKPK1XVaqwL4XZeado2bbQmQsaz1pZaaV1xTibCVpmmeYroWgnwta1UKVV1Oqul2xlt\/rhcDWGE3N0iTNe++9V33qU59SpmZpykps8+jkkgmZp+gNN9ygHnnkkcz5imaYsvNs0SJUSH+z1mOW6cImrbxey0peEFtFmgABZztf+9rX1LPPPquj6Vx33XXqyiuv7Dxhhd1zPyZ63gHKkw+TM0Qo7LL7tQigHWkClYZDaH+z1GOXaeMTUlYvFwL73UNgBs0ySdN8\/vnn1Z\/8yZ9oeOFAIm8mxkaaecYJa0m\/NuBFxye0v6gHaUPqM8v0YSPlYb7lMRmnrQO9+L11pIkHmeHUgF30l7\/8ZXX33XcrBP1++9vfrvHs50TvxYDKZAwVCrNNTz\/9tLr66qt71cyuekKEMqlhof3NUo9dpo1PSFmh7SoKuu9MEuebvjNNBJd4+OGH1Ve+8hW9ybz55pt1rF\/IUEjfira5TvnzjFO\/5SVPm9+y4ZvqO\/dcmwh9FjK778hZdeBb3x1WpolNWnlNW5NbR5qYDaYbPZwfPvGJT3Q8Aqlp+uUF4fwQ75WfG4EQfKCNytcrLSTJicf+zTTBImKSSZrz589Xt9xyiyZN2WDiv222zIRYC+oqD6HWFWl\/3r4m1ZOnTNuMi\/b1SlbKGMtWkqYAY5\/ncPecPGX6uXMuYzJXXUYWfHq5e3aFpgMWcu\/Sd08TBGqaZ9\/znveoq666qusoo0mLWZ7xb\/qakEXbLNJXXz15ywwx5eYZz17kaSVpmhfjzfijeQe4FwNRRR1p3mxV1MkyX0agzoTj0k5j9J5N8+is+3zOIuNF+uqrJ2+ZdfI2zzrGrSRNAcFeGGIjzSy70KwTh+mbjwBIMunKSfN72L4epJ0PJvXYzJu2NoTWE1pmaHlNGLFWkyYGwN49N2FQ2EYi0AsEcPbP4Aa9QJp1tAmBVpGmaJZyT9OMjMLYs22atuxLGQgwjF4ZKLKM2BBoFWli8HyvoJvOErGF1kua1PaVBBvDGIM\/24415rl4UvDzJi4evoDtlJfho0lZcc\/wmOQFCLSONF3DamqceLQVofYYY\/PlDcaFCxc6DzwnXVFoIilkbbPEL8b1C1xXMsPO4TqOOXfaavqnvLgJc+HChYqy0o1NjPISBWnaUVGwuz5x4oTasmWLfgUixk92hwjkffDgwU5A76TL8AjDFttnbiIGBwe9gQLahA3lpXuWU1bCpT4GeYmCNHF2c+DAgQ5J2vc3w6dE+1LaJJkUdg2aV2yfqXWNGjXKG5KuTdhQXtyznLKSLv0xyEsUpGlrliTNlyd\/mmZpmifbRAzp4v9SCt\/7k\/aLIW3ChvISRpq+YPgxv0kag7xEQZrcOfspgrtnPzZYAJ577rmOhSIWLZzyEkaascyHLBvMGOQlCtLkGU04aaZpnqEC1PR0LiefWLChvISRZizzIUSWY5KXKEiT3oDhpBm796xtkjWRiwUbyksYacYyH9JI0+dF3lZ8oiBNDDrvnYUtBEjVtruIaUJv\/m7f85Xf5K5mLNhQXobPGt7TdGOCqzinTp3q+rHN8hINaWZZOJmWCBABIkAEiIALAZIm5wURIAJEgAgQgUAESJqBQDEZESACRIAIEAGSJucAESACRIAIEIFABEiagUAxGREgAkSACBABkmZL5gAupA8NDTl7gyD1ixYtUrt27VJ79+5VVcRJNb0t9+\/fr3xPsUk7x4wZ0wkS35IhYDcahADlpUGDVbOmkjRrNiBlNMcVJrDq0IH2hfikfrhc98voN8sgAnkQoLzkQS3ePCTNFo591QTpgoyk2cKJFEmXKC+RDHRJ3SRplgRknYpJ2znv2bNHXbp0Sf85fPiwgvl227Ztavny5fqSMv5umnER8WP37t26i74HvG3SlGggKN\/OR02zTrOFbaG8cA5kQYCkmQWthqQNWQRAZvv27VPysPL58+c1UeJDhI+5c+eqOXPmKPPFC\/zme8DbFa\/07NmzauXKlUoIdN68efqsk6TZkIkUSTMpL5EMdEndJGmWBGSdiglZBNBeEBo+M3akGS9y1qxZmiSF7JDWfgFD+u0izZ07dzqdfUiadZotbAvlhXMgCwIkzSxoNSRtWYvA4OCg1jrtuJK2+RawuM40oaWuXr1ao2Z6y5I0GzKRImkm5SWSgS6pmyTNkoCsUzFlLQIuTdPXzzRHIPNtSmizy5YtU2vWrFFtery5TnOAbQlHgPISjhVTKkXSbOEsKGsRsM80BwYGtCnXfGjWZ561nwuC1ilnnNQ0WzjpGtwlykuDB68PTSdp9gH0qqsscxGQM0\/xnnWZZl3mWdt71sxH0qx6BrD8LAhQXrKgxbQkTc6BUhBIM8+alZA0S4GchTQYAcpLcwePpNncsatVy7kI1Go42JiaI0B5qfkAJTSPpNncsatVyxl7tlbDwcbUHAHKS80HiKTZ3AFiy4kAESACRKA+CFDTrM9YsCVEgAgQASJQcwRImjUfIDaPCBABIkAE6oMASbM+Y8GWEAEiQASIQM0RIGkWHCDzQF+Kcj3CLCHlfCHoFixYoEaPHj3sdREJrO6KnGPW7bs\/mdQ9tMmOD2s\/zut61QRXRhBeD8HXJX5tVhjNl1PMvDNnzlRbtmxRCKRQ1eere\/PmzTpIPb\/qEKC8vBTvOevXT3lBW82QmPh70kPzWfvWtPQkzQIjJgRjLrYyucx\/sy\/62xPOXEjMfBAUH2maxLV06VIdWB1fCOGY7bFjwoIMx40bp8tBOpscTVL1PRMWAqmrb1J2aLnA7ciRI2rx4sUhVTrTCI740XwOLXeBzOhFgPJyW6FNpr0W9EpeZH3ChlbWGnkVaeTIkdHNeJJmziHPom3JpJsyZYrCZBNSEm3KJE2TxJJIUwRGCNilNbq6Ju2+cOGC1mzxXzwR5tJkhVxFQI4ePaoDsEOrRT4IURFN014EpG02Pq5+mIKctw3mDjrmnXNOEciUjfLSXHlxrTVYB2KVGZJmJtF\/ObFr1+wrSrRPTLLjx48P0x5tk5VoWkmkaZOkObHPnTunyc0sB2HwUP\/kyZPVunXr1Nq1axUeow4x\/4rZGKSJ75prrlEwJ5dNmiam48ePV0NDQ8qlee\/YsUNt2LCh8\/qKmKYvXryo24XYuCEmpCwknXOaMNv3EKC8NFdeqGl2izFJM+eyZhIhzvZ8n62tnT59ehgZyKScPn26unTpkjp58qTW\/g4dOuQlNZtQzUVJXidBOTCvrl+\/vkOgZjuTSNk04drm0jK0vLQzGrTTNDmLqVi00GeeeaaLuO02hWjeWRbynNOE2b6HAOWlOGlK\/GdzUokPQNXyIhtMPBOYx3+iTYJA0sw5mqGLgL2Ym6ZaOX8008yePVuTAUy5I0aMUMeOHXOaT5NIE84sIU5CPtL0nXkKVGWRpq3lSrmmZiuOStAiTc3TRZKmyUh+X7Jkide5J2nTkHNaMJsHAcpLcdLsl7zYshS73JA0cy5zoVqKvVgIIYk2ibNEmwBMLcw84zSbmmSeFc1XyvE51vgmv1m\/y6O0KtJE\/8w24e\/YQID48KyYuWj4SNMeTl\/faZrNOfFzZqO8lE+avZIX31oTq7c5STPnIhDi2GB7zdpVyaTzaaM4m\/ORZpojkH11xHVo7yJN07XcJxRppGmactBnVzlJhC3kOHbsWG2ihSMSHI+gfbu0czgChWoyZWrLOadOlNkoL37SrLu8kDR5plnaopXmQi8OM+Zij8ptE619Poc0QgI+0ky6ciLnfygHhLJ8+fJhd0DtXSo0XlN4k659pJFmCMAu0nRpfz4StxfhNHOt3aZQzSekL0wThgDlpXpv8yrkxb7aQvPs5cuXw6Y8U7kQSLqs7bqziTJsE62YIU1vVPNqiO9KiO\/cUsyr5nUU05tW+uE7F7X7aR\/8l0WaLscGX11ok42D9FM2FoKjeM8mmY+yaqac\/eUgQHkpN7hBr+TFtFz5NvLlzJD6l9J486yQCzQqnOWZ2lLsg1v\/6ZfeQpfjVHoupiACcSJAeal+3BtPmrZWhb9ff\/31mkCxO8LfGeml+olUVQ0+bb2q+lguEWgyApSX6kev0aQJUjxw4IB2FBFN04QMWueyZcvUmjVrnBFvqoeXNeRFwHSi6kU82rztbHo+8wws1ggvTR9D88gHTnSUl2pHtLGkKYQIhxVoky7SpKZZ7eRh6c1GwJQP3INdsWKF2rp1KzeYzR5Wtr5iBBpLmtgh4xscHNRRb0zSNLUU2xlk4sSJFUPK4omAUmfOnKk9DJAh3H+F7IjMTJs2rRMMgrJS+yFsRQObICsm0I0kTRx2P\/TQQ+ruu+\/WcUYRNg5m2FtvvbXTN2iid9xxh3r1q1+t3vGOd3QtBE0bpF5JBhZJYuNHOws+WdL2anztemChmTBhQkc28Hd8EgC\/CX3oF3aol\/jEIyuNJ037bTfpkJzJmNc1rrvuOnXllVfqhWDkXY\/2U8ZYd4QIvHD\/jFr22qVZmqRJWanlsLW6UXWVFRv0Rmqa0gmcyXzmM59RX\/\/617WmOW\/ePHX77berv\/qrv1L33nuv+tznPqevoOBFD3jTciFotczVsnN1XgiSNE3KSi2nU6sbVWdZabymiQ6IIxCI8s477+yYZ+2QVDDR4uFUfFwIWi1ztexcnReCpDNNykotp1OrG1VnWWkFaSY5Apmkal83oXNDq+WuVp2r+\/lwmvcsZaVW06nVjam7rDSeNE1HIImzal854R3NVssYO1cSArynWRKQLCYaBBp5ppnmCJSkaUYzsuwoESACRIAIlI5AI0nTRMGOPSu\/UdMsfa6wQCJABIhA9AhEQ5rm6wpJz17FNiNcmwvTmSrGkFz2SxxmgIxYsKG8DF8JKCvu1TE2eWk8aYaQnKmN4ikdPGxsRj4JKaONaVzPj9n39+wL723EwewT+r9x40Y1f\/58HU4OC4KEl5NHsWXutBUbyoubMBF5DI+hyxN1scsKUIpRXqIgTSx8mzZtUtu3b1cjR47UDzyfOHFCbdmyRQ0MDLSdB5z9k90hvIsPHjzYCWpv76Zjj99rLowI2Wg+ANBWbCgv3SJDWQlfImOQlyhIU15DEZJs62IXPrVfTmmTpL1gmpoWNK\/YPlPrGjVqVNfmq63YUF7cs5yyki79MchLFKRpa5YkTT9p2ti0lRjSxf+lFKYJNhZsKC9hpBnLfAiVlVjkJQrS5M7ZP+25e\/ZjA8LEgwBioYhFC6e8hJFmLPMhlDRjkZcoSJNnNOGkyTPN4RqmoBcLNpSXMNKMZT6EkKbLKa6t+ERBmvQGDCdNegR2m2Rtz1rT85resyHLaXvS2CRAWfFvMPFLW\/GJgjQxgLx3FrZ7RqpY7iK6ELED\/ksauasZCzaUl+Gzg\/c03ZjgKs6pU6e6fmyzvERDmu3Z77InRIAIEAEi0C8ESJr9Qp71EgEiQASIQOMQIGk2bsjYYCJABIgAEegXAiTNfiHPeokAESACRKBxCJA0GzdkbDARIAJEgAj0CwGSZr+QL7leXEgfGhpyloog9YsWLVK7du1Se\/fu1fF3y\/5Mb8v9+\/erqVOnOquQdo4ZM6YT+LrstrA8IpCGAOUlDSH+7kOApNnCueEKE1h16ED7QnwSrHzrtIWTrsFdorw0ePD60HSSZh9Ar7rKqgnS1X6SZtWjyvKrQoDyUhWy7SyXpNnCcU3bOe\/Zs0ddunRJ\/zl8+LCC+Xbbtm1q+fLl+pIy\/m6acRH5Zvfu3Rop3wPeNmlKNBCUb+ejptnCSdfgLlFeGjx4fWg6SbMPoFddZcgiADLDY7rysPL58+c1UeJDhI+5c+eqOXPmdL09it98D3i74pWePXtWrVy5shNOa968efqsk6RZ9Qxg+VkQoLxkQYtpSZotnAMhiwC6DULDZ8ZQNeNFzpo1S5OkkB3S2i9gCHwu0ty5c6fT2Yek2cJJ1+AuUV4aPHh9aDpJsw+gV11lWYvA4OCg1jrtuJK2+Rb9cZ1p4l3G1atX6+6a3rIkzapnAMvPggDlJQtaTEvSbOEcKGsRcGmaPrjSHIHMt\/agzS5btkytWbNGTZo0qYUjwC41CQHKS5NGq\/9tJWn2fwxKb0FZi4B9pjkwMKBNuebDzD7zrP1sFrROOeOkpln6kLPAAghQXgqAF2FWkmYLB73MRQDwmN6zLtOsyzxre8+a+UiaLZx0De4S5aXBg9eHppM0+wB6G6tMM8+afSZptnEGsE9ZEKC8ZEGrXmlJmvUaj8a2hotAY4eODe8DApSXPoBeUpUkzZKAjL0Yxp6NfQaw\/1kQoLxkQateaUma9RoPtoYIEAEiQARqjABJs8aDw6YRASJABIhAvRAgadZrPNgaIkAEiAARqDECJM0aDw6bRgSIABEgAvVCgKRZr\/Fga4gAESACRKDGCJA0azw4bBoRIAJEgAjUCwGSZr3Gg60hAkSACBCBGiNA0qzx4LBpRIAIEAEiUC8ESJr1Gg+2hggQASJABGqMAEmzxoPDphEBIkAEiEC9ECBp1ms82BoiQASIABGoMQIkzRoPDptGBIgAESAC9UKApFmv8WBriAARIAJEoMYIkDRrPDhsGhEgAkSACNQLAZJmvcaDrSECRIAIEIEaI0DSrPHgsGlEgAgQASJQLwRImvUaD7aGCBABIkAEaowASbPGg8OmEQEiQASIQL0Q+P9IPraNi6pzfQAAAABJRU5ErkJggg==","height":251,"width":417}}
%---
%[output:5ba3c854]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAc0AAAEVCAYAAACCKL5fAAAAAXNSR0IArs4c6QAAIABJREFUeF7tXQ3QVUX538xq3jEyIcaG3oAw6WNyNKgJyQks+dvkQBOZwKvGV2UkEMobAlKEyIcEjkBJRIRaAsaETVgN0RRYMfZBhZUkFgG9oUVYEzXW2MR\/flvPde++u+frnnvvOXt+Z6axl7u7Z\/f37LO\/8zz77LPPO3PmzBnFhwgQASJABIgAEYhF4HkkzViMWIAIEAEiQASIgEaApMmJQASIABEgAkQgIQIkzYRAsRgRIAJEgAgQAZIm5wARIAJEgAgQgYQIkDQTAsViRIAIEAEiQARImpwDRIAIEAEiQAQSIkDSTAgUixEBIkAEiAARIGlyDhABIkAEiAARSIgASTMhUCyWDoF\/\/OMf6itf+Yr66le\/qn75y1\/qym94wxvUlClT1JVXXqle9KIXORvctWuX+uhHP6quvvpqtXTp0l7lnnjiCTV16lQ1cOBAtXbtWtW\/f\/9e7dxxxx3qkUceUZs3b1Z9+\/Z1vufpp59W06dPVyNGjFC33HKLLoM6XV1dvcq\/4AUvUG95y1vU+9\/\/fjV69Gh19tlnx4Lxi1\/8Qn3qU5\/SbZ577rnq2muvVdOmTVMveclLYuv6Chw+fFjdeuutavny5erCCy+sK3by5En1uc99TuN96tQp9apXvUrNmDFDjR071ov197\/\/ffXpT39a3X333V6csnT2gQceUOvXr1dbtmzR\/RSZnThxoq454Ig5Acyvuuoq1dHRUftdZLF161YtI9\/ja9ssf\/HFF0fOhSxjZJ3qIkDSrK7smzbyQ4cOaeL7y1\/+ohfEYcOGqWeeeUbt3r1bff3rX9cL+ZIlS9SLX\/ziuj7861\/\/Uh\/\/+MfVgQMH1D\/\/+U\/1+c9\/Xr3uda+rK2MuknjHjTfe2IvEGiXNd7zjHer1r3997b0goX379qk\/\/OEP6gMf+IC66aab6hZ4G8if\/exn+uPgTW96k3rf+96nfvOb36h7771XjRo1Sn8ImOSQVAggTJA7yFHISOr+6U9\/UrNnz1Z\/\/OMfdf86OzsVCBHvBHHOmjWrDiMkAfvhD3+ouru79UdH1MdF0v6Z5Xykef7556vLLrusVvT06dP6o+LXv\/61Js3bbrtNnXfeeXUfMElJE\/PElJnZH3y0XHPNNb3mW5axsQ4RIGlyDuSKwFNPPaUX6ec\/\/\/lqzZo16hWveEWtfSzWIM6Pfexj6iMf+Yj68Ic\/rJ73vOfVfgfZgmxQf8eOHeqKK65QM2fOrCtjkmafPn3UPffco974xjfWjaFR0lyxYoWaMGFCL0KHVbZx40a1cuVKNX78eCduQvx\/\/etf9fjRRzwgXRDbunXrNHkmffCx8bWvfU2tXr1aW5ADBgzoRZr33XeftjJBfq95zWt008Aa\/w4rEhjJxweICmQKS\/DZZ59VzbDCfKSJjyWx6mX8\/\/nPf7Ss8bGEDyD5CEpraWLO2DJLijHLEYE0CJA006DFsrEIYKGGWxIL9fDhw3uVB6nAosCzcOFCdc4559TKfOELX1CwLDZt2qT\/+6Mf\/UiT1Mtf\/vJaGSHN97znPdpKgdUGN61YKCjYDNJEu7CcZVEHgbpcrb\/\/\/e+1+\/iDH\/xg3SL+t7\/9TX8AwB2Jj4ZvfvObas6cOdrylMVesMG4QIIXXHCBAgEtWLBAvetd79JubYzNtDRRByQOQgXZm3jCRQyX8oYNG2ouTtQHuV5\/\/fX6gwbu8FZZmi7SBK7yofHTn\/5Uj+2Vr3xlzVWe1NIkacaqJgvkhABJMycg2YxSf\/\/739XNN9+sobjzzjtTucOEkLBXCVLFAooFH9YaFlt5hDSxSIJMQUS21dos0kQfQOwgGSzuQ4cO7SX2H\/\/4x3r\/Eh8P5l7cv\/\/9b02Q2EsFyZ111lnaunr00Uc1QQ4ePFh94xvfUHPnztVjBknigTsb1iYwgNsXLlXbPeubeyBEfJigL2KN413YZ4S1Cwtv+\/btbSdN9P873\/mOdi2jr3Dh0tLkilJUBEiaRZVMCfuF\/TYsfAiagXVkul7jhoNFEiT52c9+Vr397W9Xf\/7zn9WHPvQh9epXv7ouIMgkzfe+972anO+\/\/\/46N20zSRMkBsL2WUAYB4jPRap2v37729\/qMYLArrvuOu2uBmGA6FzBRmg7KWnKPudLX\/pS7dq1948hD1ixRSFNfBBA\/osWLdKWd1rStIOMzPl2ww039HILx81H\/k4EfAiQNDk3ckNACM3nhvO9CFYYCMV0x2JPDi7QL33pS3V7ciZpYnGVPVTTTdtM0oxbzLF3iQhXlzXo6tfOnTu1WxWuXkT6Yq\/RdEebmCUlTVjtn\/jEJ9Rjjz2mXbMui7hopGnLNQ5n2\/MQFQiE3975znfmNs\/ZULURIGlWW\/65jl6Ocbz5zW9OZWkePXpUH\/+AhYlAEbGyEEWLwCBYYxIQZC+uGACIynTTrlq1qqEjJ65AIAHqwQcf1JZkHpYm2oTrdf78+epb3\/qWtrKjgoSSkCYifGHl47+wMO0gKVPgRbI0xa0te7xpSZN7mrmqMhuLQICkyemRGwJCAPhv1J4m9q0efvhhbQ1hD1POZvo6ctFFF9UCglykCUvVdNOCgBo5pxlFmrB+4dL07Ssm3dOUgB2QGz4KJHLY55oFNnGkKUd90Db2RYcMGRIp26SkCQsZAVnmExWgkyZ6VtqE2xtHeWQvmKSZm1qyoZwRIGnmDGjVm4uLnsWRB1hqCBr6zGc+o5A4APt0x44d02c77b23H\/zgB3rBRoQs3L4u0gTmppsWZw+PHDmSObmBjzQlWAmuVN8+YVz07Gtf+9qaFQ6yR6ICnJnEOUIECAETWNyuJ4o00QZwxVnFZcuWOZM+2G0WhTQlevbxxx+vfRyRNKu+khR3\/CTN4sqmlD0TywnnE+1zmiAJWCggJSzsOOuIbEE4ooEgEPtMJgAQ1y0iPkFUTz75pC7vcseJmxbZiOLOH0ZlBIo7p3nXXXfVolttIaU5p4mIURxhAU5IqICo4Z\/\/\/Oc6mtY83yrv8JEmEh8gicEll1ziTBrhm0hJSTPtRExjaZrnNGFpytldkmZa1Fm+VQiQNFuFdIXeI1YPCEQyAuGcIo44IFMNCE8SILiCfUyoJEgILlGc\/YSV5yNNcdNib7AR0nRlBEJSBpyFlL5HpdLDgo+ITfQB45eMQG9729tqpCYfFwhSkSxBYkX\/3\/\/9nzOC1kWacrYTAUX4CHnZy17Wa6a9+93vdrpqW02aroxA+ND53e9+p3Du1swSJaSJMbk+ICS4RzCLCgQCID4MKqSWHGpOCJA0cwKSzdQjgOMncNXi7CEWRcnfikP\/b33rW\/U5RbhUQS7IYuPKMystmgFBiIL0kSbKCxm98IUvzOyetWUJqxlnLpEQYOTIkbrvUQ8if3H+EhakK\/eskDsy\/biy+MCixseEHRTkIk1xB8Md7Xt8+4+tJk37WIjMCaQaxIeCmY\/YlwdYxijHSJLknkWduCQJ1F8ikBQBkmZSpFiOCBABIkAEKo8ASbPyU4AAEAEiQASIQFIESJpJkWI5IkAEiAARqDwCJM3KTwECQASIABEgAkkRIGkmRYrliAARIAJEoPIIkDQrPwUIABEgAkSACCRFgKSZFCmWIwJEgAgQgcojQNKs\/BQgAESACBABIpAUAZJmUqRYjggQASJABCqPAEmz8lOAABABIkAEiEBSBEiaSZFiOSJABIgAEag8AiTNyk8BAkAEiAARIAJJESBpJkWK5YgAESACRKDyCJA0Kz8FCAARIAJEgAgkRYCkmRQpliMCRIAIEIHKI0DSrPwUIABEgAgQASKQFAGSZlKkWI4IEAEiQAQqjwBJs\/JTgAAQASJABIhAUgRImkmRYjkiQASIABGoPAIkzcpPAQJABIgAESACSREgaSZFiuWIABEgAkSg8giQNCs\/BQgAESACRIAIJEWApJkUKZYjAkSACBCByiNA0qz8FCAARIAIEAEikBQBkmZSpDzlnnjiCTV16lR14sSJWomtW7eqESNG1NV44IEH1IIFC9TFF1+sNm\/erPr27Vv7Xdro379\/3W933HGH2rVrl9qyZYu68MILe\/XAfLer3bihoU\/r16+va\/+RRx5RXV1dtao33HCDuuWWW+qaevrpp9X06dP1GO3f4t4pv2NsGzdu7FV87NixauXKlaqjoyNpUw2VQz8wZlsmDTXKyl4EqC\/1upR0qrRTX5555hk1f\/58vRbhGTBggHdNSjqeMpcjaTYgPSGYFStWqAkTJuiWhBzNf7MnnU2q5kJi1osiTZO4Zs+erSc1niSEY\/bHVABpc+DAgbodlLPJ0SRVF6EmhdM1Nmk7abvAbffu3WrmzJlJX1srJ2M9ePCg80MmdYOsEIsA9aX3B2gsaP8r0E59kTVN1i3Xx3bScYRQjqSZUYpprC0hxeHDh6vjx48rISWxpkzSNEksijRlAUo7kaXfJ0+eVLBs8V+fJSvkij7DEtuzZ0\/NWkY9WIWNWJq2FW2TdpS1KZhl6YPUheiBAR5amhkVIWE16kt59cUWsevjJ+E0CKIYSTOjGNNMHPNLbd++fb1crrbLSiytKNK0v\/ZMEj127JgmN7MduEJBsEOHDlVLlixRixcvVps2bUrk\/hW3MUgTz7Bhw7RLOgthCdxRX86wtgcNGqTdxC7Le+3ater2229XsBLxiGv61KlTda5yl5sc5YH3vffeq26++WaNhXwUmC7zjNOC1TwIUF\/Kqy+2SMVVbOpmlSY+STOjtG2Xha8Z21o7fPhwLzIQ0hw9erQ6ffq0OnDggLb+du7c6SU1m3TMRWncuHHaXYt24F5dunRpjUDNfkaRsunCtd2ljVh5JmlG7WminOlyFlexWOk9PT11xG33KYkLyZYNSTOjMiSoRn1pnDTbrS8Qs6wzVd7XJGkmUHhXkaSLgL2Ym65a2X80y4wfP16TAVy5ffr0UXv37nW6T6NIE\/urSYKEfKTp2\/MUHPIiTds9awdEwbKVQCVYkabl6SJJWNdiXcrvs2bNqu0323IkaWac\/BmqUV8aJ81260te8QwZpk+hqpA0M4ojqbvJXixkoRZrElGxNgGYkXK+L7oo96xE7ko7vsAaH2ma73e5YJpFmhCF2Sf8jQ8IEN\/Ro0frrG4fadrijAoqImlmnPwZqlFf8ifNVupLko\/wDNOilFVImhnFliSwwY6atV8lhOSzRnGMxUeacYFA9tER1\/6eizSF5NFX355FHGmakam+dqIIW76oOzs7tYsWe44IPIL17bLOEYyU1JIxZUDSzDj5M1SjvvhJs+j6wkjz+glP0sywAEiVuBB6CZgxF3vUtV209v4cyggJ+Egz6siJ7P+hHRBKd3e3jhK1I0Rt4jKVI8pCiyPNJJC6SNMVPesjcXsRjnPXuvpE0kwiqfzKUF+aH23eDH2JW4vymyHlaImk2aCcog5ru85s4nW2i1bckGY0qnk0JG1yA3GvmsdRzGhaGbJvX9SGxE6ckBdpugIbfO9Cn2wcZJzyYSE4SqKJuOg+kmaDkz9DdepLvskNmq0vUd6yOP3KMD1KUYWkWQoxVbeTrsCp6qLhH3mUO97co7YXWdMy8R3RId7lQYD60nxZkTSbjzHf0AACPmu9gSaDqwqvhJy9xbEZECiIEu54HHHC2WBJQoF\/F7e9WQ7RyfPmzVOrVq1ypmwMDrRAB0R9ab5gSZrNx5hvyICA6RZqdT7aDN0tVBVx7YMo7RzIJlHiSA+iklFO8B45cqT3iE6hBsnO1CFAfWndhAiSNOlyat0E4puKhwBcdD6rEbqxf\/9+HYW8bt06NXjw4BpJmlZo8UbFHhGBYiAQHGnS5VSMicVetAeBKIvRJFM5zmNaliTN9siMby0XAsGRJr6ko1xOQ4YMKZeE2NtSInDkyJGW91sIE9HEdiJ9CRBZvXp1zWULkoyyNKkrLRdhJV\/YDl1pBOjgSDPJQlA2ITUi4Cx1sVgSo2jk4jCK+z2LXKLqINhnypQp6syZM+qss86qpRNEHbEwL7\/8cr13KYSKD8zt27fXEt9feumlCnmL5Zq7Vo8hb0xa0R4xSoZyFE5lwzAo0nS5pkyXU9+bv5tMwixFBHJC4Ok7L8+pJX8zOJd6zTXXqGnTpun\/ubYoQJh33XVXXeJ+nLPbsWOHeuihh9Rjjz2m5syZo8tcccUVirrSdLHxBRYCrdCVPEAPijQBSJSlyYUgjynDNtIg0IqFwJUwAH1ctGiROuecc\/Q1ceYjZzVxNdyhQ4fUww8\/rH\/GFz+uXEPELXUljZRZNg8EWqErefQzONKM2tPkQpDHlGEbaRBox0Lgi541dQNjiAqao66kkTLL5oFAO3QlS7+DI8246FkGN2SZJqyTBYF27AtHRc\/apCnEiSvX7ExBYnlmGTfrEIG0CLRDV9L2UcoHR5oYGM9pZp0OrFdmBKKiZ0UvJLIcf5v7\/VEJEcqMCftOBPJGIEjSzBsktkcEio5Akow+pqXpIkme0yy6lNm\/IiBA0iyCFNgHItAAAkkIM6mlOXHiRKbRa0AWrBo+ApUhTTPCMOquyPBF\/twI7ahL86of825N5n59DjMzDV1HR4cqAk6+6Fn71hJ7T9O+9snUC+pL75WA+pJudSyirqQbgbt0JUjTdEUh4GH+\/Pmq6ompsWAuW7ZMTZ48Wd9qEZVijW67\/yqPfe0S\/s2cS6HgRH3pvVhSX9LRTci6UgnShACXL1+u1qxZo3B1kv0FlG46hFnadPGNGTNGzZ07Vy1cuFATqhmRDPyq+MiiibGfPn1aJzzHv4WIE\/UlfoZTX\/wYha4rlSBNLPrbtm3TCx1caiSB3hPetC769etX95ERdWtG\/PISRglxbSJXq9wS0tPTEyRO1Jf4OUt98WMUuq5UgjRty5Kk2XvC+y4nhmVZddI0L3nGHZRCmgcPHqxd9hwSTtSXeNKkvrgxqoKuVII0+eUcvQhgAUD+UrHEbfdc1UkT+IwaNUqnlzMJhZZmPLmEWIL64pdqFXSlEqTJPZroSY5fzauk8LUY4l5dlgXcjI416yOiGBc9I79raHu\/1BfqC3XFj0AlSJPRgO4J4Iv2tM\/9hRIVmmUhsOuYliajZ\/NAtDxtUF\/SySpUXakEaULUPHdWP+F9FpSc1SzC+cN0Ktqa0qGePbPRo75QXxrVqFB1pTKk2egEYH0iQASIABEgAiRNzgEiQASIABEgAgkRIGkmBIrFiAARIAJEgAiQNDkHiAARIAJEgAgkRICkmRAoFiMCRIAIEAEiQNIMZA4ggUNXV5dzNEhSP2PGDLVhwwa1efNmnX8378eMtrRv1zDfJf0cMGCA2rJli85ty4cItBoB6kurEQ\/nfSTNcGRZG4krTWCzUwfaB+KjYLWTJwQoAg6pRAhQX0okrAJ0laRZACHk3YVmE6SrvyTNvKXI9lqFAPWlVUiH8R6SZhhyrBtF3Jfzpk2b9PVW+N+uXbsU3LerV69W3d3dCknI8bfpxkUmlI0bN+p3+C7wtkkz6oJjWpoBTroSD4n6UmLhtaHrJM02gN7sVyZZBECW2FPs7OzUFykfP35cEyWe6dOnq4kTJ6oJEybUJSjHb74LvF35So8ePapz2gqBTpo0SSc9J2k2ewaw\/TQIUF\/SoMWyJM0A50CSRQDDliTtZk5NM+\/suHHjNEkK2aGOfWOMwOcizfXr1zuDfUiaAU66Eg+J+lJi4bWh6yTNNoDe7FfmtQiMGTNGW51w2ZqP7b7Fb649TeSeXLBgga5qRsuSNJs9A9h+GgSoL2nQYlmSZoBzIK9FwGVp+uCKCwQy7yCENWtePRagCDikEiFAfSmRsArQVZJmAYSQdxfyWgTsPc2Ojg5lX8Drc8\/a1yjB6pQ9TlqaeUuc7TWCAPWlEfSqV5ekGaDM81wEAI8ZPetyzbrcs3b0rFmPpBngpCvxkKgvJRZeG7pO0mwD6CG+Ms49a46ZpBniDOCY0iBAfUmDVrHKkjSLJY\/S9oaLQGlFx463AQHqSxtAz+mVJM2cgKx6M8w9W\/UZwPGnQYD6kgatYpUlaRZLHuwNESACRIAIFBgBkmaBhcOuEQEiQASIQLEQIGkWSx7sDREgAkSACBQYAZJmg8Ix9yakKdd9kpIdx5dNZ+rUqap\/\/\/69EqVLjljXvZPmu31HQaKGhz7Zqe7sewZdCdoR\/YpMQcgjK6n40sJoHmMx644dO1atXLlS4UxoM58kx2ia+f6qtk19uSWT6NutL9JpWR98FzdkGlzJKpE0GxCYTKAVK1bo5OZ4hBzNf7PPLNqkai4kZj0oio80TeKaPXu2zhGLJwnhmP2x09uBDAcOHKjbQTmbHE1SbURxXGNLq5DAbffu3WrmzJmppGjKTVIFypibTdapOhpYYerLDQ19ZNprQav0RaahuW40ovtln9YkzYwSTGNtCSkOHz5c3yZiL9AmaZokFkWaojBCwC6r0TU06ffJkye1ZYv\/4rYTlyUrSiI3oOzZs0fnkoVVi3qwChuxNO1FQPqWhMAEs0b6AHzsMfbt2zfjjGC1KASoL+XXl7w+mMuuKSTNjBJ0fTX7mhLrEwS3b9++Xtaj7bKSr7go0rRJ0iTRY8eOaXIz28F9mHj\/0KFD1ZIlS9TixYsV7tVM4v4VtzFIE8+wYcMU3MmNEFaUpQlre9CgQaqrq0u5LO+1a9eq22+\/vZZIXlzTp06d0v06ceKE7qfLTW7LKM1innGqsNr\/bsex5Ul9ST412q0voifocaMfzMlHXcySJM2McjGJEHt7vse2ZA4fPtyLDIQ0R48erS+GPnDggLb+du7c6SU1W4lMEpdE62gH7tWlS5c6L4+OIuUoV0weVl7cHg3wNF3O4ioWK7Snp6eOuO0+JbG88xhHxulTuWrUl8Y\/MuUieHPySAxAs\/UF8tu+fbv2LOGy+kY+mMs++UmaGSWYdBGwF2bTVSv7j2aZ8ePHazKAK7dPnz5q7969TvdpFGlifzVJkJCPNH17ngJVHmTjere0a1q2EqgEK9K0VFwkCetarEv5fdasWbX9Zp+ooz4eMk4PVrMQoL40Tpq2V6hV+iJWJi6mz8PLVHblIGlmlGBS96y9WAghiTWJvUSbAEwrzNzjNLsa5Z4Vy1fa8W3a+8jCfL\/pHm02aaJ9s0\/4Gx8QID7ckGIuGj7StMWZJGAhqSwzThVWS+Gepb64p0uUropeNEtf8G7oyObNm5VsgdDSpFqnRiDJXpgdNWu\/RAjJZ41ib85HmnGBQPbREdf+nksRzYujXYSJMcRZmoKNXF7taifJItDZ2aldtAhEwj4KrG+XdQ6XUVJLxiVoG8vUk4EVYhGgvvgtzSLri903l2u4ahHntDRj1d1fIC6EXlwZ5mJvko78u70\/hzJCAj7SjDpyIvt\/aEf2IOwzoLZVB4vXVJAoCy2ONJNA6iJNV\/Ssj8TtRTjOXWtb6eLKRRCREDO+pBk9m0R62cpQX5ofbd4MfTGlnYfuZ5s9xalF0mxQFlGHtV1nNvE620UrbhXT5WEeDfEdCfHtW4p71TyOYkbTypB9+6I2JHbihDwUxxcI5HsX+mTjIG3Ih4XgKNGzPktZPhgksCJLYogGp01lq1Nf8k1u0Cp9kQmbh+6XffIXmjSjXIxRGV3Mr60kxw7KLsSQ++8KnAp5vBwbEWgEAepLI+glq1tY0oSlJecJ4TIzb1fHsQ2cd5SD9SBQcUWa5bBpPW\/ePLVq1Srn4f1kELFUOxHwWevt7BPfTQSKigD1pfmSKSxp2kMXdyWI0j4XaRIlDuAj0hLlxA06cuTI2GMHzYeab0iDgBlE1ap8tGn6x7JEoEgIUF9aJ43SkCbcDj6rEV9X+\/fv15GV69atU4MHD66RpGmFtg5WvokIlAMBbmWUQ07sZXEQKAVpRlmMJpnKEQXTsiRpFmeysSfFQoBbGcWSB3tTDgQKT5pCmIiQtJODy6b36tWray5bkGSUpTlkyJBySIa9LDUCR44cKXz\/YWVGbWVQVwovwiA6WAZdMYEuNGki2GfKlCnqzJkz6qyzzqpLwC0W5uWXX673LoVQJUeiHKy\/9NJLFXKxytVdWAjKJqRWawYxikc8DqO43+Pf0PwSST4wqSvRciiDnJs\/k+LfEIVT2TAsLGnirN0111yjpk2bpv\/nciWBMO+66666ZOQ4m7djxw710EMPqccee0zNmTNHl7niiitU35u\/Gy9dliACOSLw9J2X59hafk25tjzMrQzqSn5Ys6VkCBRVV+zeF5Y0XYeg0flFixapc845R199ZT5yyBfXXR06dEg9\/PDD+md8xeAaKUTcciFINnlZKj8EirwQRFma1JX85gBbSoZAkXWlNO5Zs6O+6FlzXwblo4IbuBAkm7wslR8CRV4IovY0qSv5zQG2lAyBIutK6UgzKnrWJk0hTlwj5UqPxuCGZBOYpRpHoOj7gXHRs9SVxucAW0iGQNF1pVSkGRU9i4HYpGnuy0QlREgmSpYiAmEjwHOaYcuXo8sfgcLuaWKoSTL6mKTpIkme08x\/0rBFIkAEiEBVESgsaSYhzKSWJm4clyMnVRU0x00EiAARIAKNI1BY0vRFz9q3ltjuWfviZ7kX0mwv6q7IxiEtTws2xuZVWubdmsz9+pxMzZSNuHw3VJyoL731mPqSbm0LVVcKS5rpxBNd2nTbyqXDVU\/ijo+LZcuWqcmTJ+sbYKLSEdLF\/d\/5ZV+7hH\/DBdYyl0LBifrSez2hvqRbkUPWlUqQJgS4fPlytWbNGoVrxuwvoHTTIczSpjt8zJgxau7cuWrhwoWaUM0oS+BXxUcWTYz99OnT+nIA\/FuIOFFf4mc49cWPUei6UgnSxKK\/bds2vdDBpUYS6D3hTeuiX79+dR8ZUTfMxC8vYZSQbQDkNZYbdXp6eoLEifoSP2epL36MQteVSpCmbVmSNHtPeN9F3rAsq06a5oXouK9VSBP5jYHb5s2btQcjFJyoL\/GkSX1xY1QFXakEafLLOXoRwAKAXL9iidvuuVDIIH4pdJcAPqMCwci2AAAbcUlEQVRGjdKpGE1CoaWZFdFy16O++OVXBV2pBGlyjyZ6kuNX89o1fC2GuFeXZak2o2PN+ogoxqXoyIUc2t4v9YX6Ql3xI1AJ0mQ0oN+CsgkTf9tnZEOJCs2yENh1TEsTvzF6Ng9Uy9GGTw+oL275haorlSBNiJTnzuonts+CkrOaoZ4\/bHR5DvXsmY0L9YX6Ql1xI1AZ0mx0ArA+ESACRIAIEAGSJucAESACRIAIEIGECJA0EwLFYkSACBABIkAESJqcA0SACBABIkAEEiJA0kwIFIsRASJABIgAESBpBjIHkMChq6vLORokqZ8xY4basGFDLXtN3sM2oy3tm2jMd0k\/BwwYoLZs2aJz2\/IhAq1GgPrSasTDeR9JMxxZ1kbiShPY7NSB9oH4KFjt5AkBioBDKhEC1JcSCasAXSVpFkAIeXeh2QTp6i9JM28psr1WIUB9aRXSYbyHpBmGHOtGEfflvGnTJn29Ff63a9cuBfft6tWrVXd3t0IScvwtScjRMDKhbNy4Ub\/Dd4G3TZq+y8DRBi3NACddiYdEfSmx8NrQdZJmG0Bv9iuTLAIgS+wpdnZ26lRwx48f10SJZ\/r06WrixIlqwoQJdQnK8ZuZNs4chytf6dGjR3VOWyHQSZMm6aTnJM1mzwC2nwYB6ksatFiWpBngHEiyCGDYkqTdzKlp5tEcN26cJkkhO9Sxb4wR+FykuX79emewD0kzwElX4iFRX0osvDZ0naTZBtCb\/cq8FoExY8ZoqxMuW\/Ox3bf4zbWniTytCxYs0FXNaFmSZrNnANtPgwD1JQ1aLEvSDHAO5LUIuCxNH1xxgUDmHYSwZs2rxwIUAYdUIgSoLyUSVgG6StIsgBDy7kJei4C9p9nR0aGDgswLq33uWfsaJVidssdJSzNvibO9RhCgvjSCXvXqkjQDlHmeiwDgMaNnXa5Zl3vWjp4165E0A5x0JR4S9aXEwmtD10mabQA9xFfGuWfNMZM0Q5wBHFMaBKgvadAqVlmSZrHkUdrecBEorejY8TYgQH1pA+g5vZKkmROQVW+GuWerPgM4\/jQIUF\/SoFWssiTNYsmDvSECRIAIEIECI0DSLLBw2DUiQASIABEoFgIkzWLJg70hAkSACBCBAiNA0mxQOObehDTluk9SsuP4sulMnTpV9e\/fv1eidMkR67p30ny37yhI1PDQJzvVnX3PoCtBO6JfkSkIeWQlFV9aGM1jLGbdsWPHqpUrVyqcCW3mY2Yrwnt4v2cz0X6uberLLZmAbre+iM5LdrAVK1bo3NRVfEiaDUhdCMacQLIYm\/9mn1m0SdVcSMx6UBQfaZrENXv2bJ0jFk8SwjH7Y6e3AxkOHDhQt4NyNjmapOq78SQJpK6xSdtJ2wVuu3fvVjNnzkzyyroyeD\/eZ97mkroRVkiFAPXlhoY+Mu21oFX6IusF1gp8JEetS6kmREkLkzQzCi6NtSWkOHz4cH2biJCSWFMmaZokFjU5RWGEgF1Wo2to0u+TJ09qyxb\/xW0nLktWlEVuQNmzZ4\/OJQurFvVgFTZiadqLgPTNxsc1DsEsSx\/SvCfj9GA1CwHqS3n1xV5rqj65SZoZZ4Drq9nXlFifILh9+\/b1sh5tl5VYWlGkaZOkObGPHTumyc1sB\/dh4v1Dhw5VS5YsUYsXL1a4VzOJ+1fcxiBNPMOGDVNwJ2chLMEoytKEtT1o0CDV1dWlXJb32rVr1e23315LJC+u6VOnTul+Ic0fHpebHP+e1EWYcWqwmgMB6kt59SXpB3lVJj5JM6OkTSLE3p7vsa21w4cP9yIDWcRHjx6tL4Y+cOCAtv527tzpJTWbdMxFSRKtox24V5cuXeq8PDqKlE0Xru0ubcTKM0lTLrY2sZM9Tfyb6XIWV7FYoT09PXXEbfcpStHtBbzq7qaMKpCqGvWlcdJsl77IVgZ0Dx\/ZUR+kqSZFSQuTNDMKLukiYC\/mpqtW9h\/NMuPHj9dkAFdunz591N69e53u0yjSxAZ9kiAhH1n49jwFqrxI07ZypV3TspVAJViRpuXpIklY12Jdyu+zZs2KDVhIYwVlnC6Vr0Z9aZw026UvEoQkXp+qf2SSNDMuZ0kXWnuxEEISaxJ7iTYBmJFyvqjOKPesWL7Sji+wxjf5zfe7ouSaRZoQhdkn\/I0PCBAfbkgxFw0fadriTBJUlIZgM06XylejvuRPmq3SF99aU9UIWpJmxuUsSWCDHTVrv0omnc8axd6cjzTjAoHsoyOu\/T0XaZpHMXxKEUeaScLTowhbyLGzs1O7aBGIhMAjWN8u6xzBSEktGZe4ky7oGacKqymlqC9+0iy6vthrTdX1haTZwJIWF0IvATPmYo\/X2S5ae38OZYQEfKQZdeRE9v\/QDgilu7u71xlQ+ysVFq+pvFEWWhxpJoHURZquqFYfiduLcJy71uyTTbA8fpJEYo2Xob40P9q8Gfpi6xrds2fOnGlcHarbQlQkpuvMJpCyXbTihjSjUc2jIb4jIb59S3GvmsdRzGhakZZvX9SWpp04IS\/SdAU2+N6FPtk4yDjlw0JwlOjZKPdREhd4dWd180ZOfck3uUGr9MX8oK56IpCgLU2Q1v79+xMd+G\/eMsGWG0HAFTjVSHuh1wVey5cvV2vWrFF9+\/bVwzWJysy4xIUwvNlAfWm+TIMlTU6e5k+eVrzBZ6234t1le4cdfQzSFGKEmx4BYrCwxW2P\/z9q1Cj973Cd4m9mSCqb1Ov7S31pvvyCJE24P5ctW6bRw7nHJKnlmg8135AGATOIqlX5aNP0r2hlQXrYu164cKHasWNHzdIEkc6bN0+tWrVKZ33yeV9ArnPnztX1XdmhijZe9qceAepL62ZEkKSJhQFHFAYPHkz3bOvmEt9UAARs96wspiNHjtTnVU1L0+wuLc0CCI9dKAUCwZEmvpglTRzSvnFPsxTzkJ3MCQHXnqZphdjBUVG\/5dQlNkMEgkIgONI092lcrqghQ4YEJUAOppgIHDlypC0ds0kzqXvWtkjReepKW0RYuZe2S1eyAh0UacLKvPbaa9Xjjz9ehwf2xJDkWxaCsgkpq3Cz1sNiSYyi0YvDKO73rLKJq\/ftb39bn8398pe\/rC644AK9h4nr06ATTz75pA78gZ6sXr26tncp+5nnn3++Ou+882o317RrDHFjLNLvxCiZNKJwKhuGQZGmBABNnjxZLwjr1q3TZ\/vuu+8+ddFFF6m+N383mYRZigjkhMDTd16eU0vxzcCqvO666\/Q54AcffFCT5k9+8hM1ZcoU9clPflJdffXV+v8fOnRIXwaA4KCrrrpKbdiwQT311FPqpS99qb79BtG01JV4vFkiXwRaqSuN9Dwo0rSB+OIXv6hwgB7Zba6\/\/nouBI3MFNbNhECrFgKJnkWu3rvvvrtmaYJIZ8yYUfMcnHvuueqSSy7RZX71q19pz8yzzz6rxzZnzhyFC83xkDQziZuVGkCgVbrSQBd11aBJ0z6jxoWg0enC+mkRaPVCkCV61nXchLqSVtIs3ygCrdaVrP0NmjRd4fUMbsg6VVgvLQLt2BdOGz2LMfnOaFJX0kqc5bMi0A5dydrXYEkThIkcpExskHVqsF4ZEcgSPcvEBmWUNPvcLgSCJE3fAe52gcz3EoFWIWCTpn3syj6CEmVptqrPfA8RKBMCwZEmCbNM0499zRuBJJbm9u3b63LM0tLMWwpsL2QEgiJN+zJXERyyoMjdlnDZRt0VGbKw7bHZ1zSZ2WJMLJn79TnkbMutaDi59jTNC8ld1zq5SNOcG9SX\/8qf+pJudSy6rqQbzXOlgyJNHwhmFC3un5s\/f76SXJxZgSt7PftMq+m26+zsrMOI1nv9oimXiuNfzbkUCk7Ul97aTX1Jt+LZt0yFpCuVIM24fZ500yHM0mYatTFjxtTdeMFk3v+9ONy+OQf\/Zt4MEgpO1Jd4Hae++DEKXVcqQZpYzLZt21aLpA1lcYtX7eQlTOuiX79+dRcZu4JHkrccRknXzTk9PT1B4kR9iZ+z1Bc\/RqHrSiVI0\/atkzR7T3jTtWjjU3XS9N2cc\/DgwbqLm0PBifoST5rUFzdGVdCVSpAmv5yjFwH7TGtcBGb8khJWCd\/NObQ0w5Jz0tFQX\/xIVUFXKkGa3KOJnuT4FTdjyGNHU1bZMvdFZCOieN68eWrRokVq4cKF+oKAUHCivlBfkn5AmOWqoiuVIE1GA7pVwBftad+tGEpUaJaFwK5jui5Digh0LX74kGK0+XPIUF\/SaVCoulIJ0oSoee6sfsJHnWmdMGGCzkc6ffp0hX07ntN8DrtQz57ZyyH1hfqSjiJ7lw5VVypDmo1OANYnAkSACBABIkDS5BwgAkSACBABIpAQAZJmQqBYjAgQASJABIgASZNzgAgQASJABIhAQgRImgmBYjEiQASIABEgAiTNQOaAeZOFPSQcG5gxY4basGFD3ZVQeQ7djLbcunWrGjFihLN56afrto08+8O2iEAUAtQXzo+sCJA0syJX4HquQ\/bNPnjvupLKBxHvbyzw5Klg16gvFRR6A0MmaTYAXlGrNpsgXeMmaRZ1NrBfcQhQX+IQ4u8mAiTNAOdD3Jfzpk2b1OnTp\/X\/du3apbO+rF69WnV3d+tkBvh78+bNqm\/fvhodZELZuHGj\/v++C4lt0pSsQmjfrkdLM8BJV+IhUV9KLLw2dJ2k2QbQm\/3KJIsAyGzLli1KLpw+fvy4Jko8yAQ0ceJEhcxAUamwzHG48pUePXpU57QVAp00aZLe6yRpNnsGsP00CFBf0qDFsiTNAOdAkkUAw5Yk7WZOTTPv7Lhx49T8+fOVkB3q2DfGCHwu0ly\/fr0mZiQzNx+SZoCTrsRDor6UWHht6DpJsw2gN\/uVeS0CY8aMqeWfNftsu2\/xm2tPE1bqggULdFUzWpak2ewZwPbTIEB9SYMWy5I0A5wDeS0CLkvTB1dcIJB5ByGs2blz59au1ApQBBxSiRCgvpRIWAXoKkmzAELIuwt5LQL2nmZHR4cOCjpx4oRauXKlwt8+96x9jRKsTtnjpKWZt8TZXiMIUF8aQa96dUmaAco8z0UA8JjRsy7XrMs9a0fPmvVImgFOuhIPifpSYuG1oeskzTaAHuIr49yz5phJmiHOAI4pDQLUlzRoFassSbNY8ihtb7gIlFZ07HgbEKC+tAH0nF5J0swJyKo3w9yzVZ8BHH8aBKgvadAqVlmSZrHkwd4QASJABIhAgREgaRZYOOwaESACRIAIFAsBkmax5MHeEAEiQASIQIERIGkWWDjsGhEgAkSACBQLAZJmg\/IwN\/SlKdclzJJSzpeCburUqap\/\/\/69bheRxOp2\/la8y3y37\/xk1PDQJzs\/rH05r+tWExwZQVJ3JF+X\/LVpYTTPfpp1x44d2ytxQtq248r73r1ixQqdpJ5P8xCgvtySCdx26gs6bKbExN9RF81nGmCJKpE0GxCWEIy52MrkMv\/NPuhvTzhzITHrQVF8pGkS1+zZs3VidTx2ph7X8Mz+2DlhQYYDBw7U7aCcTY4mqfquCUsCqWts0nbSdoHb7t271cyZM5O80llGcMSP5nVomRtkRS8C1JcbGvrItNeCVumLrE\/4oJW1Rm5FkusDqzTtSZoZpZ3G2pJJN3z4cIXJJqQkaehM0jRJLIo0RWGEgF1Wo2to0u+TJ09qyxb\/dd1EgrpCrqIge\/bs0QnYYdWiHpSoEUvTXgSkbzY+rnGYipy1D+YXdJW\/nDOqQKpq1Jfy6otrrcE6UFWdIWmmUv3nCru+mn1NifWJSbZv375e1qPtshJLK4o0bZI0J\/axY8c0uZnt4BJpvH\/o0KFqyZIlavHixQqXUSdx\/4rbGKSJZ9iwYQru5LxJ08R00KBBqqurS7ks77Vr16rbb79dX5iNR1zTp06d0v1CbtwkLqQ0JJ1xmrDa\/xCgvpRXX2hp1qsxSTPjsmYSIfb2fI9trR0+fLgXGcikHD16tDp9+rQ6cOCAtv527tzpJTWbUM1FSW4nQTtwry5durRGoGY\/o0jZdOHa7tI8rLy4PRr003Q5i6tYrNCenp464rb7lMTyTrOQZ5wmrPY\/BKgvjZMmPnztR2IAmq0v8oGJD9Us8RMhKQJJM6M0ky4C9mJuumpl\/9EsM378eE0GcOX26dNH7d271+k+jSJNBLMkCRLykaZvz1Ogyos0bStX2jUtWwlUghVpWp4ukjRdRvL7rFmzvME9UR8NGacFq3kQoL40Tprt0hdbl6quNyTNjMtcUivFXiyEkMSaRFSsTQCmFWbucZpdjXLPiuUr7fgCa3yT33y\/K6K0WaSJ8Zl9wt\/4gADx4Voxc9HwkaYtTt\/Y6ZrNOPEzVqO+5E+ardIX31pT1WhzkmbGRSBJYIMdNWu\/SiadzxrF3pyPNOMCgeyjI65NexdpmqHlPqWII03TlYMxu9qJImwhx87OTu2iRSASAo9gfbuscwQCJbVk8rSWM06dSlajvvhJs+j6QtLknmZui1ZcCL0EzJiLPV5uu2jt\/TmUERLwkWbUkRPZ\/0M7IJTu7u5eZ0Dtr1RYvKbyRh37iCPNJAC7SNNl\/flI3F6E49y1dp+SWj5JxsIyyRCgvjQ\/2rwZ+mIfbaF79syZM8mmPEu5EIg6rO06s4k2bBetuCHNaFTzaIjvSIhv31Lcq+ZxFDOaVsbh2xe1x2lv\/OdFmq7ABt+70CcbBxmnfFgIjhI9G+U+SmuZcvbngwD1Jd\/kBq3SF9Nz5fuQz2eGFL+V0rtnhVxgUWEvz7SWqi7c4k+\/+B66Aqfia7EEEagmAtSX5su99KRpW1X4e9SoUZpA8XWEv5nppfkTqVlv8FnrzXof2yUCZUaA+tJ86ZWaNEGK27Zt04EiYmmakMHqnDt3rlq4cKFy5W5tPrx8Q1YEzCCqVuSjzdpP1iMCRUCA+tI6KZSWNIUQEbACa9JFmrQ0WzeR+KZyImAGjlQ1LVo5JcdetwuB0pImlB3PmDFjdNYbkzTNr66qniVq14Tie8uDgPlRieQR8+bNU6tWraJXpjwiZE\/bgEApSROb3ffee6+69dZbdZ5RpI2DG3batGk1CGGJzpkzR5199tnqyiuvrGWFGTJkSBtg5iurhsCRI0cKP2R8eCJpBD445UNz5MiR1JXCSy6sDpZBV0zES0ma9t1uMiBxL5nHNS677DJ13nnn6YWh783fDWu2cTSFR+DpOy8vbB+xrTF48OAaSeJvPNSVwoos6I4VWVdKT5oyALiX7rnnHvW9731PW5qTJk1SN954o3r00UfVbbfdpu6\/\/359BAU3eiCalqQZtM4VcnBFXQhcliVJs5BTqDKdKqqu2AIopaWJQUggEIjypptuqrln7ZRUcNHi4lQ8JM3K6F9hBlrkhYCWZmGmCTuCNb3AXpkgLM2oQCCTVO3jJtzTpH62CoGi79VwT7NVM4HviUOg6LpSetI0A4Ekz6p95IRnNOOmKX+vOgKMnq36DOD4syBQSvdsXCBQlKWZBSTWIQKhIsBzmqFKluNqFgKlJE0TDDv3rPxGS7NZU4btEgEiQASqi0BlSNO8XSHq2qsqTQX7xgkzEYQZUMU0ds\/NClhm+\/fvr93rGSpO1JfeKwH1Jd3qGKqulJ40k4jRtEZxlQ4uNjYPcSdpI7Qy2AtetmyZmjx5ss4AgwVBMsLI5c+CkXkUITQc0ozHvkECdc25FApO1Jfes4L6kkZTet8ZHJKuVII0sdgtX75crVmzRvXt21df8GxaC+mmQ5ilzXN7SE1oJrpnDt\/\/3oGKjww8p0+f1pYm\/i1EnKgv8TpOffFjFLquVII05TYULHQdHR28Mswx303rol+\/fnUfGaYVWtXbYuR4BjLoyAdXT09PkDhRX+JJk\/rixyh0XakEadqWJS2n3hPedC3a+FSdNLFALlmyRGeW2rNnT400Dx48WHdfayg4UV\/iSZP64saoCrpSCdLkl3P0IoAFAInvxRK33XOhkEH8UuguYV5sbhIKLc2siJa7HvXFL78q6EolSJN7NNGTHL8iOYQ89nGdKlvmdlpGwQgRxQicWrRoUe2S81Bwor5QX7J81lRFVypBmowG9FtQNmHibzuZdyhRoVkWAruOaWmGFBFojpP6Qn2hrvgRqARpYvg8d1Y\/CXxfhXJWM9Tzh40uBqGePbNxob5QX6grbgQqQ5qNTgDWJwJEgAgQASJA0uQcIAJEgAgQASKQEAGSZkKgWIwIEAEiQASIAEmTc4AIEAEiQASIQEIESJoJgWIxIkAEiAARIAIkzUDmAM4IdnV1OUeDJPUzZsxQGzZsUJs3b9b5d\/N+zGjLrVu3qhEjRjhfIf0cMGCA2rJli04Wz4cItBoB6kurEQ\/nfSTNcGRZG4nrkH2zD97bB+KjYOVdpwFOuhIPifpSYuG1oeskzTaA3uxXNpsgXf0naTZbqmy\/WQhQX5qFbJjtkjQDlGvcl\/OmTZv09Vb4365duxTct6tXr1bd3d0KScjxt+nGRUagjRs3aqR8F3jbpClZhdC+XY+WZoCTrsRDor6UWHht6DpJsw2gN\/uVSRYBkBn2FOXC6ePHj2uixDN9+nQ1ceJENWHChLq7R\/Gb7wJvV77So0eP6py2QqCTJk3Se50kzWbPALafBgHqSxq0WJakGeAcSLIIYNiSpN3MLWvmnR03bpwmSSE71LFvjBH4XKS5fv16Z7APSTPASVfiIVFfSiy8NnSdpNkG0Jv9yrwWgTFjxmirEy5b87Hdt\/jNtaeJPK0LFizQVc1oWZJms2cA20+DAPUlDVosS9IMcA7ktQi4LE0fXHGBQOYdhLBm586dW7tSK0ARcEglQoD6UiJhFaCrJM0CCCHvLuS1CNh7mh0dHcq+gNfnnrWvE4PVKXuctDTzljjbawQB6ksj6FWvLkkzQJnnuQgAHjN61uWadbln7ehZsx5JM8BJV+IhUV9KLLw2dJ2k2QbQQ3xlnHvWHDNJM8QZwDGlQYD6kgatYpUlaRZLHqXtDReB0oqOHW8DAtSXNoCe0ytJmjkBWfVmmHu26jOA40+DAPUlDVrFKkvSLJY82BsiQASIABEoMAIkzQILh10jAkSACBCBYiFA0iyWPNgbIkAEiAARKDACJM0CC4ddIwJEgAgQgWIhQNIsljzYGyJABIgAESgwAiTNAguHXSMCRIAIEIFiIUDSLJY82BsiQASIABEoMAIkzQILh10jAkSACBCBYiFA0iyWPNgbIkAEiAARKDACJM0CC4ddIwJEgAgQgWIhQNIsljzYGyJABIgAESgwAiTNAguHXSMCRIAIEIFiIUDSLJY82BsiQASIABEoMAIkzQILh10jAkSACBCBYiFA0iyWPNgbIkAEiAARKDACJM0CC4ddIwJEgAgQgWIhQNIsljzYGyJABIgAESgwAiTNAguHXSMCRIAIEIFiIfD\/9uvlY902Uo4AAAAASUVORK5CYII=","height":251,"width":417}}
%---
%[output:7c442b8c]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAc0AAAEWCAYAAAAEvMzxAAAAAXNSR0IArs4c6QAAIABJREFUeF7tXQ3QVsdVXmL9wQg2YKpSwnyhgm2RRgWVMAFKCWWChanYhB+1hCBGLME04NdAUCT8hCLEmFQxUqRVG2g\/pSmkVkyalOBgVaJShCjVL4S2qHwSO6BT\/0acZ\/G83fd+92fv++69d+\/e585kArx77+4+u+c8e86ePTvk6tWrVxUfIkAEiAARIAJEIBOBISTNTIxYgAgQASJABIiARoCkyYlABIgAESACRMASAZKmJVAsRgSIABEgAkSApMk5QASIABEgAkTAEgGSpiVQLEYEiAARIAJEgKTJOUAEiAARIAJEwBIBkqYlUCxGBIgAESACRICkyTlABIgAESACRMASAZKmJVBVF\/v85z+vlixZop566ik1ZcqUxOa89tpravny5WrRokVq4cKFCu+tXbtW7du3T40bN67qbiTW\/8EPflA9+eSTsb+\/8Y1vVO9+97vVe9\/7XnXjjTfqMl\/84hfVsmXL1IULFwa9g\/LTpk1T73vf+xT+jEfww58\/\/OEPq3e84x2xdX384x9X69atU7fccovau3evGjFiRGKbUfaJJ55IxFbaeN999+mxKPv53\/\/9X3X8+HH1u7\/7u7r\/V65c0XhEsYy266WXXlJ33323mjhxovr1X\/91dcMNN7QV+drXvqYefPBB9bnPfU6PWdx8tJmv8h18fPv27Wro0KFt42RW+o3f+I3qR37kR\/QcePvb365e97rXZcL5la98RX\/3j\/\/4j9W3fMu3qHe9610KY\/Fd3\/Vdme8mFfi3f\/s3tXHjRvXDP\/zDg8b03\/\/939Xv\/M7vaBlF3SNHjlT33HOPbvP1118f+8k\/+ZM\/UR\/60IfUb\/zGb6TOtY4bzBedI0DSdA5pMR+0UUKouc6kCeUGgh82bFgLxP\/6r\/9Sx44d04oISvPXfu3XtBIXQvrO7\/xOddttt7WBfu7cOfVHf\/RH6q1vfatWRt\/93d\/dpox\/6qd+Sv3iL\/7iIMUrSvzw4cO1J83Lly+rzZs3q0996lPqR3\/0R9WcOXM0Kf3lX\/6lxnL48OFq9+7davz48W3YIUEYlDgWBP\/5n\/+pdu7cqWbMmBFLmsAJhIkxkcWMFLSZr2mkOWvWLD1+8ly6dEkdPXpUk9FP\/\/RPq\/e\/\/\/26P0kP5sDP\/MzPaLJaunSpAqFhsYS5ENdeG6kFpo8++qgmxkceeaSNNIVMX3zxRV3f93\/\/96u\/\/uu\/Vnv27FG333672rRpk\/q2b\/u2VjXA+c\/+7M\/0fAd2WQs0m\/axTDkIkDTLwbnrWmyUUN1JE32MUx5QMJ\/4xCe0BShWopDmvHnz1Ac+8IFB+D7\/\/PPqZ3\/2Z9WGDRv0Sl\/wgwU6MDCg64ECNR988\/7771ew0GCZZCkyXy3N\/\/mf\/9HK\/WMf+5h6\/PHH1fTp09WQIUNaXQWhgHSwOJFFiPz4T\/\/0T+ree+\/VlvjLL7+syRXk+83f\/M2t983FBf7xF37hFzTWZh028zWNNKOkhHpA4iB0WLewIBcsWBArV0L8WDj91m\/9Vsvb8Hd\/93faCwMyxZywfTAfTp48qev8i7\/4C\/1atH0g9NWrV2u8zUUG5iE8Hr\/5m7\/Z+ndY\/B\/96Ee1l+K\/\/\/u\/rRZotm1lueIRIGkWj7GTGuKUEJTjoUOHtAvtS1\/6krYm4H4CiaS5Z6F8YCXA0njllVfUzTffrH7iJ35CLV68OHH1\/ld\/9Vda0UDJmq5NKKhf+ZVf0atqtAMPrLunn35awTp485vfrF1UIDdT8UZBgXs2iTRR9uzZs9odC8UEV2cWaYIYYZFMnTpV4yH4wcIEGT788MODXLSwIOCaBJmcPn3aOWmKF+A973mPxnnXrl3qX\/7lX9Q73\/lOTTxjxoxxMldAdnCv\/uRP\/qRatWpVG5lJBRj\/j3zkI1r5m9YmlPzP\/\/zPa2vq1KlTekxR7i1vecsg0sQ8gqWPsUaZH\/iBH2iVKYI08fF\/\/dd\/1SQE9ywIFKQefWARot\/f933fp3EVMofX4pd+6ZcUyBoE+MILL+hFEhYF4j5HnzA30H4Q7pve9KbWXIOLuLe3V\/+7yJfUDYvyM5\/5jCZ00+oWyxjjIXVgrmMOwuMBdznGImuB5mRi8CNOECBpOoGx+I9ElRDICqvXX\/3VX1V33nmngjvrz\/\/8z\/WKGAQq+2jRPU0oDCiF5557rs2NhJUvLJKoG0l6BvfTAw88oK0z07UJpY+VO4gUq3jsdYHQQLAoiz0bfFssviSkskgTyhwkiNU53I1ZpAlrCu2ZO3euWrNmTYs0sbf76U9\/WpOW2Q\/0D66ymTNnKrybRuDSh7yWppAmlDoeITQoYShrUdLdzqbf\/u3f1gsi9BXEYfugDcAE1iYI6Z\/\/+Z\/1QgXK3iRf00IE6YBIgKdptRZFmugL+geSQf+i7mX8joUgSOrnfu7nBu074l24rOGxgLsU\/f3CF76gse\/p6VF\/+Id\/qOcLFjSYO\/K9gwcP6jn9Dd\/wDW0xA1nYyv4wSBrzFg\/qQnwBLNK+vj514MABkmYWkB79TtL0aDDSmhJVQkIKEtyAlbfpxhT3UZQ04UZav369tgYR7CLP3\/zN32i33LZt2wbtYUkZWB8i4OLaxPdhmUCJwZKEkoWCkH1GWMNbtmzRpADiTAqISCJNvI+FAL4BS0HcbUmkCQwQHIQ2IFAF5IG2mPjBCsW\/my5aWGcgzccee0xBQRZNmuZ+IqwRLDzEKrYJckmaK+g\/xh77ZSCG6F5j2hwTTOEZwH9CjsDLDAiKulWxWAOpgqTETVskaWLRg0VhUlCc9MOch0kLnX\/4h3\/Q2IPAYJmj\/ZgvkJG4cYjGDKThKfucf\/\/3f68t0LgAJCy8SJo1UcL\/30ySZk3GK6qEYHnB7Ri1Jv7xH\/9Rr4QRjBCNnv2e7\/kerVD\/9E\/\/VCudb\/3Wb231HvssCPqAqzBujxAFxe2Hb8CyFNdsf3+\/fhdKAsT7Hd\/xHXq1DivAlgDSomdRNwJOfvmXf7llWaRFz6I86oVrDiSOP5v4QXkBo4ceeqjlosWCAAsHuOpAnEWS5q233trmNhQcsV+GRUE0WjXPFBVCO3\/+fG7rBRhE3bFwHWIs4X6UvbooacJtKXuo4qYtkjSzvi3zFJZvNLI3zjuARRLmNFy9iJaGNyMpwtaWNIERvECoD5hGg9VMEidp5pnh1ZclaVY\/BlYtiCoKCCPcntGAFtnPgSsoSpqjR4\/W7lMowqTnx37sx7S1Gbf\/KMry9a9\/vXZrffWrX9WrdDnCAOX\/zDPPaPcv9jOxN4jAG+z\/\/NAP\/VDmnqYZPQurEq4yWMYgN+yJwjUmT1r0LMh60qRJer9N9rNM\/LD3hvaLi\/Y\/\/uM\/tOsZdeC\/LFdxktUSxTR65CRN4Wa5eq0myf8XQvtx1CSPpSl7hSAOLIAk0lM8GsBTAoLiAnjg0sVCTNy0CLrJOiKVNxBIMPjkJz+pidyFpYlvSjsw\/8yAnTjMbUhTIpfxPez3z549O3ZfGd+npZlnZvtRlqTpxzhktsKWNGXvEXucSaSJyuRcXGbFkQIgXChjuJugUKG88PdooMiJEyc0OSPYAgQKMk7aL0UVcUQF1yxW\/XBlbt26VSGARkgwa08z2q8ofhIIhUUH2gdihmWCfS2zLc8++6yO2jUfcX1nEV00eCmLNOEyh6WGwCzzkffgppYn7Rwp2gXiS9vThFWN8VixYoX2LsjeG45mxD1w80pAUBzZ4R0scMRNi4VJUaSJ\/VZYZ0lnj233NMV1Le5xsVCTXLPoYxZp4luYL\/C+YF8Ux6TSHpJmXg1UfXmSZvVjYNUCF+5ZKGNYC3ADxh25sGkIiBIBOVAsIEY5QJ50Zg7EB8UAkob7z4ywNOtLsu5kXwiBS6abq1vSlH7A4sS+1t\/+7d+2LClb0pTgJPQrzv0W\/V0ULhY0IBd5xD0LIouLCM1LmlnRs6gPbQaxgghBwOgzIrHh0o66JkH+GD9Ykmg3LHN4LKKLL\/OoC9ziOH6RloyjE0szySI251JW9CwWBugP9tfRZnhWsAd811136X\/HPEtKfpFGmiBKLCLxgDDHjh2bKVIkzUyIvCtA0vRuSOIbFCXNL3\/5y9o1iuwocC1KINDv\/\/7va6tJwujjAoFgXeB3KAmx3OBOQxAElF3aGTYzbB\/7ZnKcBK1GXQj2gQKGO08euKmgTDohTXwDSnvlypXa3SoH07slTYkUxRk8BLoAC4lutHXPiusSkZCwPs29SCh3WBzACPuUcI2LwsVYmftmsIywFwzXcNIRkTzTVIjgD\/7gD2LPaeL4EIKesIDBPICbHXu8iLSNnslEvUJUIBt4GL792789ljRRVty0sFzxuCRN85wm9p0lujWKTZ5zmnKOEiSHxQy2FnB8yjzfaX4\/iTQvXryoj0PhwWLhDW94g9WQkTStYPKqEEnTq+FIbkzckRMQJM6dQdlDgUAZQthxYDopelYsN7gncVQFrjlE9\/3e7\/2eJiUbgZfoRViusFjh0sQD8kEkLYKREIn4vd\/7verMmTOaLBGQAYWcZJGmEZUZFYzv45weiAYEn5TcIIpkXPAIMMD3YBHA1XfTTTfp12xJE+2SRQqIBOdkkToNR34++9nPaosM4wDXNBYnpsUI6w7BWvgGMLfF3na6YiyweEIEsWQE+qZv+qZWdiUQpox1XLBPtB6MIQKxsGhBhps4S1PeETctSLZT0ozLCHTkyBHtSofFi\/\/SgswkKhZ781hcSkYgE2dxy2JrQeamLMYgF3Fu2jjSlONf2L\/EfBR5MDGEJwL7+tGHpGk7o\/0pR9L0ZyxSWxKn9GElQUEhchGH8SdMmKAtP7jcsJ+UlHsWbrH9+\/frjDEgHyh6BPNAudgcUZAI3be97W16ZQ5lLA8sDezN4aA3FJxN\/k0bogLZw3JDmjL0D4Eq3ZKmWIpQZmY\/bEkT7YbChJsaQVlI94coZAmAguWOMRFrXhTuD\/7gD+pD7dirheX+4z\/+49qStsE+z3SFZQaiwTjDesJiCskmUB+Cs+CelPOpcGnG5ZmV+syAIJAxFmt44vbGxdLFOHVKmtF+AlMsvJAQAEdzrrvuukwoYOWDyOJyz4orGS5pLPywwJPxFNc1XOXRFIJxpCnuYJxJTnriMhyhLEkzcxi9K0DS9G5I2KBQERCFC+WfdKwn1L6zX0QgFARImqGMJPvhPQIkTe+HiA0kApkIkDQzIWIBIuAGAZKmGxz5FSJQJQIkzSrRZ92NQoCk2ajhZmcDRYCkGejAsltEgAgQASLgHgGSpntM+UUiQASIABEIFAGSZqADy24RASJABIiAewRImu4x5ReJABEgAkQgUARImoEOLLtFBIgAESAC7hEgabrHlF8kAkSACBCBQBEgaQY6sOwWESACRIAIuEeApOkeU36RCBABIkAEAkWApBnowLJbRIAIEAEi4B4BkqZ7TPlFIkAEiAARCBQBkmagA8tuEQEiQASIgHsESJruMeUXiQARIAJEIFAESJqBDiy7RQSIABEgAu4RIGm6x5RfJAJEgAgQgUARIGkGOrDsFhEgAkSACLhHgKTpHlN+kQgQASJABAJFgKQZ6MCyW0SACBABIuAeAZKme0z5RSJABIgAEQgUAZJmoAPLbhEBIkAEiIB7BEia7jHlF4kAESACRCBQBEiagQ7sxz\/+cbVu3bpBvbvlllvU3r171YgRI0rp+Re\/+EW1bNkydd9996mFCxeWUicrIQJ5EahaXj7\/+c+rJUuWtJp97733qg984AN5u8HyJSBA0iwB5CqqECXw1FNPqSlTpugmCIFNmjRJbd++XQ0dOjS1aa+99pras2ePWr16dWbZuA+ZiuiRRx4haVYxEVinFQJVygvkbPny5WrMmDFaLr\/2ta\/pv0NuSZxWw1dqIZJmqXCXV1mcEoAwPvjgg+r8+fOZ1mZUkLMINtqzD37wg+rJJ59U06ZNU8eOHVMkzfLGnjXlR6BqeTFbnEdO8\/eUb3SLAEmzWwQ9fT9t5Txv3jxtPUYJVCzRO+64Q128eFEdPnxY927UqFFq3759aty4cUrIEP+O7yRZrCg3Y8YM\/T7cTiRNTycKm6URqFpezGEQObzxxhszF7ccvvIRIGmWj3kpNdrs0cg+irhwTcUxfvz4NpcRLE0QIYgUBDpy5EgrF5LUQdIsZdhZSYcI+CIvYmVCzriv2eFgFvwaSbNggKv6fNzKWVyuAwMDg4gvanmi3XH7LLLvIiQKUkwLLCJpVjUDWG8eBHyQF5MwTe9Onn6wbPEIkDSLx7iSGuKUQJwbCtYjiA0BB2vXrtUuV\/w5KTjh5MmTbf3JEm6SZiXDz0pzIuCDvJhbH\/TM5BzAEouTNEsEu8yqbJWAkJoE7IirNok0TUvTpj8kTRuUWKZqBKqWF0aaVz0D7OsnadpjVauSttGAQo6wIM0znOIqQqcl2CduTzOLREmatZo2jW1slfJiyiD3Mf2fgiRN\/8eooxYmBTbEuVPFLRQVWPMbYoGaLiSbRAkkzY6Gjy+VjECV8hJNbCBdt5GvkmFidUopkianQesYiZkIgbDUC4Go4jXHMm2hE7cwqlfPy2+t4El5KR97H2okafowChW2QVxDaEKZ6fUq7HJwVWMMN23apDZu3KjTI4JAodgxnmfPnlVHjx5tZZbBv+NBsJdZ7tKlS6q3t1ft2LFDn8flE48A5YUzg6TZ4DlgWidcNYczEUSxgxglhaL0ziTKZ599Vp07d04TqOxhT506lekOE6YC5SUcGemmJ0GSJl1O3UwJvlt3BJBRJslqhGwcP35cB3c9\/vjjqqenp0WSphVadwzYfiJQFALBkSZdTkVNFX63DgikWYwmmY4ePVqnUTQtS5JmHUaYbawageBIEyvpNJfT2LFjq8ac9TcAgf7+\/tJ7KYSJCOno7RiSz3Tnzp0tly1IMs3SpKyUPoSNrLAKWekG6OBI00YR1G2QuhngTt6FsiRG6chlYZT1eyfjkvYOgn3uvvtudfXqVXXdddep6JVwcNfOnDlT710KoWKBeeDAASVZnm699VY1f\/78lru27D64xqSM7xEjO5TTcKobhkGRZpxrynQ59d85xG6EWSoVgck3PU+ELBF47dGZliU7L3bhwgV11113qXvuuUf\/F7dFAcJ87LHH2pKAI1VbX1+feuaZZ9SZM2fU\/fffr8vcfvvtirLS+XiYb1JW7HEsQ1bsW5NcMijSRDfTLE0qAhdTRikqAnscy1AE4noFeZrPhg0b1PXXX6\/WrVvX9u9yaB4XjL\/88svqxRdf1L9jxb9lyxbtvqWs2I9xWknKij2OZciKfWsaRJppe5pUBC6mDEkzD4pVKIKk6FlTNtCHtKA5ykqeUU4uS9K0x7EKWbFv3ddLBmdpZkXP1s1\/3smgdvsOMcpGMAujrN+za+isRFr0bJQ0hThxSXhcyraq+tBZz6t5ixjZ4c49TTucKiuVdk6TEYGVDUvjKi47mCotehbgR0nT3O+PS4hAWWnclK2sw2XLSjcdDc7S7AYMvpsPgSavsn3ru01GH5M040iS5zTzzf88pX2bL3na3m3Z0PpO0ux2RjT4\/dCEIc9Q+tR3G8K0tTQXLVrENHp5JoJlWZ\/mi2WTnRULre8kTWdTo3kfCk0Y8oygT31Pip6N5hOOumeFbA8fPqy7zrsc88yAfGV9mi\/5Wt596dD63hjSNBULlcM1QYgqW5zbW7hwof7NvBh33rx5rYuoTRFyIQxJkZ6i0BcvXqxeffXVVpan7kXYzRek7zY4uamx3K9QXgbj3Y28UFb6rXRKubO8s9oaQZrm\/g2iBKM5NzuDrt5vgZS2bt2qli5dqq+CSstLmrTX1XRFcPr06ba5FMqeIOVlsGx3Ky+UlXBkpRGkCULYtm2b2rVrl75v0LzpYejQofVmP0etN\/fFZs+erdasWaPWr1+vCdU8xgP85ClCEcgFvzNmzGi5DE1L01ztV3mzPfp+4sQJK5wcDVFpn6G8ZEOdV14oK+HISiNIE0p\/\/\/79LRdjEglki0q4JUzrYuTIkW2LjCQXapYiGPHACy3Akg4um9\/GRchyeTL+vGzZMoUE40KaK1asaCOpuHOHZY0Q+n7kyBErnMpqk6t6KC\/ZSOaVF8pKOLLSCNKMWpYkzcFKwXQtRvEpizQPHjyoG2ZeimzuaS5YsEATqZkuriprE0oQgTZC8rDA0+6xzFbD\/pSgvGSPRV55cU2alJXsMSqqRCNIkyvn9OkDBQAiwsXEcFdH3XM+kabpZi9KKGy+S0vTBqUwy3QiL1WQJmWlmPnXCNLkHk3y5IkLXoHrqYo9TRv37PLly5WcJaxybxpK8NixYwpJ0bP2fosR3eK+SnlxLy9ZpGkzmnm3MigrNqjmL9MI0mQ0YPzESIr2jB6WLzN6tk6BQIyeza9w6vxGN\/LimjQRoEdZqWY2NYI0AS3PnbVPMPN8ofmLnNW0OX\/oQhFUM+27r5XnNLvHsE5f6FZeKCs8p1mn+c62FoQAFUF\/Qcjys6EhQFkJR1YaY2mGJoQ+9IeKIBxF4MN8CrkNlJVwZIWkGbKkFtw3KoJwFEHBU6Xxn6eshCMrJM3Gi3PnAFARhKMIOp8FfNMGAcpKOLJC0rSZ8SwTi4ALRZB1QwfO2C5ZsqStfkkgf+jQIbVu3TplJppHQUQV4uaOffv26TSA8sRFP+Lfenp6cl+H5aLvnFbNQcDFfKGs+DFfSJp+jEPXrYgjF\/kosuasXLlS7d69W+3du1fn33XxuFIEvb29aseOHS2CM89fnjx5si3rjnkcBn04cOCAmjVrllq1apXukkQ5DgwMkDRdDHKg3yhbXigrtDQDFaUwuhWXJrCI1IFFKQLzcP3Zs2fbSBMjJDlnYSGeOnVKDRs2TCEvLRYDkv3p8uXLraQDNpamJKmfPn262rx5sxo1atQg0jVnh4u+hzHb6t+LMuTFxXyJy8xFWSl\/\/tHSLB\/zwmssgiDjGp2lCPrvHNJ6bWzf1dh+xymCPJbmuXPn9HdxK8qUKVM0wU6cOFH19fXlJk1kUME3kPs2K9tQVt8LH2RW4AyBMuQla75QVpwNZ+EfImkWDnH5FWStnPfs2aOuXLmi\/8PeH9y3uE1k7dq1Cu7QaBJ0yTyCnpgXeLtSBNEk7KaVl7WnCdIEYR49elRbm5s2bVKrV69WW7ZsyU2aZurAaCq56Chm9b38UWeNnSJQhrxkzRdb0qSsdDrK7t4jabrD0psv2SgBCZQZPXq0vkj5\/Pnzer8TT1LOSvxmXuDtShGYe5p5btgQN62Q5Zw5c7S7NnqFmAxM3FViEggUvUOUpOnNdC68IWXICwLW+vuT9\/VsSZOyUvh0yKyApJkJUf0K2CgB9ApuSDxmVKkZaDN\/\/nxNkrieC25LPOaNMRMmTEhVBDbIxbln065dMr9pkiDeOXPmjJo7d66KEqC8E3flmdzZOX78+MTFQtxF5VkLBpu+s4wfCJQhL1ikppGmDRKUFRuUii9D0iwe49JrcKUEQD6wOuGyNR9x306ePLkQRSARsCBquF7NOyuTSBN9hnsZx0xwibbpao2+g1W\/PNFcu8OHD9e3lzAQqPRpW1mFZcgLZKgI0qSslD9tSJrlY154ja6UQJylaTY+JGvLvAlHrOq0gQqp74VPSM8rKENeQpovTZcVkqbnAt1J81wpgYULFw6KIjUv4HXhnu2kf0W803RFUASmdflmGfLiwj3rC55NlxWSpi8z0WE7XCoBNMuMnjUja0NaPeeFv8l9z4uV7+XLkBcXWxm+45jUvtBkhaRZ15noQbtDE4Y8kDa573lwYtlrCDR5voTWd5ImpbpjBCAMTX66DexoMnZN6ztlhWn0mjbn2d8MBMxk0k899VTriEr0NUlWkBWdSsCJQMgIUF7qO7q0NOs7dmw5ESACRIAIlIwASbNkwFkdESACRIAI1BcBkmZ9xy615ciWYx7il8LRvLJFdT9691\/0zsui6uV3iUAnCFQtL9Jmycj10ksvpd6y00kf+Y4bBEiabnD07iuiBMz9RSGySZMmqe3bt6u49HBmR3AeC8ndkQA9q6z5ngi+5LN99tlnNYGn7XV6ByAb1CgEqpQXE2ju+fs\/7Uia\/o9RRy2MUwJRMku7jFoOMI8ZM8aKYNMaKYqA1mZHQ8mXSkDAB3kR+UQiBAbKlTDoHVZB0uwQON9fS1s5z5s3T1uP5u0mIFCxRO+44w518eJFfW0YHlOAzUQH+I6NxYq2PPHEE3Q3+T5pGtw+H+RF5OTGG29UAwMDlBdP5yNJ09OB6bZZNns0YgGK29RUHHLrh2lpgjDlSjEkRTcvbU5qr\/nOuHHjuu0W3ycChSBQtbyIZ2fRokUKd8SKnFFmChnurj5K0uwKPn9fjls5i2DKKtYkvqjliZ6BFIU04Toy\/449ThAiiBf3cKa5esWChWUq15H5ixxb1kQEqpYX1H\/gwAEtS4gjIGn6OwtJmv6OTVcti1MC+GD034X4QGa4WkuILbqnKaQZvSbMZu8lz15qV53my0SgQwSqlBdZVN53330KlyTQO9PhIJb0GkmzJKDLrsZWCYiLdtq0afoeSXHVJpFmJ4FBQprAwGYPtGysWB8RqFJeklzDGBVGnPs3N0ma\/o2JkxbZRgMKOcKCNM9wxhFd3J5mHIlGCRffXrJkiWL0rJOh5UcKQKBKeYl2h5ZmAQPs8JMkTYdg+vSppNVrnDtVImLvvffetj1H8xuy4k26JizadyY38Gk2sC1ZCFQtL2b7SJpZo1Xt716TprgOBSLTVZGmvOOUfbUw+127YElXkN\/jxNb5gQDlxY9xqKoV3pImXHybNm1SGzdu1JGZ5kWxZ8+eVUePHm1ZRZjEeBDMYpa7dOmS6u3tVTt27FAM3Y6fYuJKxa9ZUbBVTVLWSwR8QYDy4stIVNcOb0kzColMVhDjlClT2n42iRIp23DOCeVkX27q1Kk6Ko1POwKmJU8rk7ODCKQjQHnhDAECtSFN7JElWY1wxx4\/flwu1HH0AAAgAElEQVRHZj7++OOqp6enRZKmFcohJwJEoB0BbmVwRhCBfAjUgjTTLEaTTEePHq1Tw5mWJUkz34Rg6eYgwK2M5ow1e+oOAe9JUwgTUZ\/RbDISoblz586WyxYkmWZpjh071h16\/BIRSECgv7\/fe2xgZaZtZVBWvB\/CIBpYB1kxgfaaNBHsc\/fdd6urV6+q6667ru2gr1iYM2fO1HuXQqiSjkoy19x6661q\/vz5LXctFEHdBqlsySBG2YhnYZT1e3YNxZewWWBSVtLHoQ7jXPxMyq4hDae6YegtaV64cEHddddd6p577tH\/xbmSQJiPPfaYMs8X4gB9X1+feuaZZ9SZM2fU\/fffr8vcfvvtqv\/OIdmjyxKZCEy+6fnMMixwDYHXHp3pJRRxWx7mVgZlxc2wUVbscfRVVqI98JY0o4fjpeEbNmxQ119\/vb7U2Hwkmw2SHb\/88svqxRdf1D9jFbNlyxbtvqUisJ\/AaSWpCOxx9FkRpFmalBX7MaasuMHKZ1mpjXvWbGhS9Ky5L4PyacENVARuJjdJ0x5HnxVB2p4mZcV+jEmabrDyWVZqR5pp0bNR0hTiRK5TM5eqdLpu\/nM30zHfV4hRNl5ZGGX9nl1D8SWyomfr0IfiUUqvgRjZjQD3NO1wclIqLXoWFURJ09yXiUuIwIhAJ8PCj1ggUIcgmrRzmpQVi0FmEScI1EFWpKPe7mmigTYZfUzSjCNJntN0MqdjP9LkVXaT+17cjAr3y02eL6H13VvStCFMW0tz0aJFTKNXgD4KTRjyQNTkvufBiWWvIdDk+RJa370lzaTo2WiO1Kh7Vsj28OHDerJGr7uiELtDIDRhyINMk\/ueByeWJWmGJivekqZrYTNJmER6Dd20Oy\/Ny6nnzZun8\/oOHTq0bVhCE4Y8c076boNTnu\/6UpbyMngkupEXykq\/CkVWGkGa5l4nImqj+Wl9UVRltgMW+datW9XSpUv1tWlpOXyT9oVdKIKko0TiMVi8eLF69dVXW+neysQorS70\/fTp021zKZT9c8rL4JHvVl4oK+HISiNIE4p527ZtateuXfpuTvNWlKj15ItSLrsd5h7y7Nmz1Zo1a9T69es1oZpHE4CfPE1XBCdOnLDCqeyx7LY+yks2gnnlhbISjqw0gjSh9Pfv399yMSaRQLaohFvCtC5GjhzZtshIsgazFMGIB15oAZZ0cDn6bVhrTz75pJoxY0ZrT9q0NE0XWdw53LJGCH0\/cuSIFU5ltclVPZSXbCTzygtlJRxZaQRpRi1LkuZgpWC6FqP4lEWaly5dUmjH3r17Ff68bNkyhRtshDRXrFjRZtnFJbbIVnduSkAJIihN2gsLPO3OVze1lvMVyks2znnlxTVpUlayx6ioEo0gTa6c06cPFAAS5EuwT9Q9VxZpHjx4UDcUN9bE7WkuWLBAEynaKk9V1iYtzaJUkv\/f7UReXJMmZaW6edII0uQeTfIEiwtegeupij1NG0Vg7k1XJzbXzt0dO3ZM4QKBrL3fKtvZSd2UF\/fykkWaNuNkLl4pKzaIFVOmEaTJaMD4yZMU7RlNLFFW9KyNy2n58uVKklVUGdDF6NliFJLPX+1GXlyTJmWlupnSCNIEvDx31j7JzDNT5i+4j3ThwoVWZ6pcKwJE6tYpEAj5MkM5exZVQZQXt\/JCWQlHVhpDmtWtS8Kt2YUiqCs6Te57XcesynY3eb6E1neSZpWSVPO6QxOGPMPR5L7nwYllryHQ5PkSWt9JmpTqjhEITRjyANHkvufBiWVJmqHJCkmTUt0xAqEJQx4gmtz3PDixLEkzNFkhaVKqO0bAhTBk3WaDM7ZLlixpa6MkkD906JBat26dkuAlKYRgItxys2\/fPp0G0Px3\/BnnQM1\/6+npyX11nIu+dww8X6wdAi7mC2XFj2EnafoxDl23Io5c5KNIALBy5Uq1e\/dunW3HzB\/bTcWuFEFvb6\/asWNHi+DMoyQnT55sy7pjHodB2w8cOKBmzZqlVq1apbsi0awDAwMkzW4GN\/B3y5YXykp\/MDOKpBnMUH69I3FpAotIHViUIjAP1589e7aNNNFLSZ8HC\/HUqVNq2LBhCin2sBiQ7E+XL19uJR2wsTQlSf306dPV5s2b1ahRowaRrjlVXPQ9wKlXyy6VIS8u5ktcZi7KSvlTjqRZPuaF11gEQcY1OksR9N85pPXa2L6rsf2OUwR5LM1z587p7yLB+5QpUzTBTpw4UfX19eUmTSROwDfgvs1KnJDV98IHmRU4Q6AMecmaL5QVZ8NZ+IdImoVDXH4FWSvnPXv2qCtXruj\/sPcH9y0So69du1bBHRrN5yoJB9AT8wJvV4ogmk\/WtPKy9jRBmiDMo0ePamtz06ZNavXq1WrLli25SdNMHRhNJRcdxay+lz\/qrLFTBMqQl6z5YkualJVOR9ndeyRNd1h68yUbJSCBMqNHj9YXKZ8\/f17vd+JJSlWH38wLvF0pAnNPM88NG+KmFbKcM2eOdtdGb0ORgYm7FQULArh5o3eIkjS9mc6FN6QMeUHAGjJIJT22pElZKXw6ZFZA0syEqH4FbJQAeiVRpGZOTTPQZv78+ZokFy9erN2WeMwbYyZMmJCqCGyQi3PPpl27ZH7TJEG8c+bMGTV37txBBCjvxF15JtePjR8\/PnGxEHdRedaCwabvLOMHAmXICxapaaRpgwRlxQal4suQNIvHuPQaXCkBWF+wOuGyNR9x306ePLkQRSARsCBquF7NOyuTSBN9hnsZx0xwibbpao2+g1W\/PNFcu8OHD9e3lzAQqPRpW1mFZcgLZKgI0qSslD9tSJrlY154ja6UQJylaTY+JGvLvAlHrOq0gQqp74VPSM8rKENeQpovTZcVkqbnAt1J81wpAdx2Et1jNC\/gdeGe7aR\/RbzTdEVQBKZ1+WYZ8uLCPesLnk2XFZKmLzPRYTtcKgE0y4yeNSNrQ1o954W\/yX3Pi5Xv5cuQFxdbGb7jmNS+0GSFpFnXmehBu0MThjyQNrnveXBi2WsINHm+hNZ3kialumMEIAxNfroN7Ggydk3rO2WFafSaNufZ3wwEzGTSTz31VOuISvQ1SVaQFZ1KwIlAyAhQXuo7urQ06zt2bDkRIAJEgAiUjABJs2TAWR0RIAJEgAjUFwGSZn3HLrXlOCpiHuKXwtG8skV1X8LSzcQIZt7aourld4lAJwhULS9os9mGsuS0E6ya\/g5JM9AZIAJo7i\/KPsqkSZPU9u3bVVx6OBMOEB+SuyMBelbZKIxS13333Zf7gudAh4Td8hiBquXFzGgFmJDeEZetmxemewxfo5pG0gx0uOOUgOSVleTsaZdRi6U4ZswYK4KNwhhXf6BQs1sBIFClvIhcAkabxWwAcNe6CyTNWg9fcuPTVs5YwcJ6NG83AYGKdXjHHXeoixcv6mvD8JiRrmaiA3wnScjNcvhGWtlAh4DdqhECVcqLmT+WlqX\/k4ak6f8YddRCmz0aOf4hLlxTccitH6alCSKUK8WQFN28tNlsZNSivXTpEt1NHY0iXyoLgSrlRRarb3\/729XnPvc5deHCBS4yyxr4DuohaXYAWh1eiVs5y4p2YGCgdRuIEF\/U8kQf8ZuQJojQ\/Dv2OEGiIF7cw5nm6s3jFq4DtmxjeAhUKS9CmjfeeKOWJS4y\/Z5fJE2\/x6fj1iXtKUb\/XYgPbiFcrSXBB9E9TSHN6DVhtkkKbAm24w7zRSLQBQJVykvUPctFZhcDWcKrJM0SQK6iClslIC7aadOm6XskxVWbRJqdBAZRCVQxA1hnHgSqlJdoIBDaHY03yNMXli0WAZJmsfhW9nXbaEDzPKV5Niwuoi9uTzOORKOE++Uvf1nvafL4SWXTgRVnIFClvKBpqP+JJ57Q2yZ4eOTE3ylL0vR3bLpqWVJgQ5w7VSJdo8kHzG+IBZp0TVi0sWZuTfzGxAZdDSdfLhiBquVFiFMSklBeCh7wLj5P0uwCvFBeFSJMS7QeSl\/ZDyLQLQKUl24RrPf7QZKmuWrkii19goorFaWyomDrPdXZeiLQPQKUl+4xrPsXgiNN8xZ2HIvAhvrixYsTr6qq+wB2034JAsI3aGV2g2T175pjGR1Pc986mmQizgVffW\/8bAHlxc9xKbtVwZEmXCczZswgSZY9k1hfZQiAFDdt2qQ2btyoz8vGLRynTp2qcwBDPvDgiJFZDmcDe3t71Y4dO9S4ceMq6wsrJgK+IxAUaSLic+vWrepNb3qT2rx5s8a+avds\/51DSpsDY\/uutuqyrRfv2JQ1v11ah1hRRwiIZQliRGanNWvWqPXr12syNIny2WefVefOndMEKtHSQq4dVez5S9F5niQvWXIUJwtxMkSZ8XxCdNi84EgT7lg8yIkqB\/KhFKZMmaL\/fezYsR1C1dlrz016pbMXO3jr9pdubr1lWy\/esSlrfruDpjXulf7+\/sr6jMhlsRrRiG3btqldu3ZpK9T87eDBg6qnp6d1C41phVYhK0UDZjPP0YY8ciRlk75Nucke1SplJbt1g0sESZrmHmacIihzkGysuE4Grsp3uIK+tvhKm0dZvxc1flGL0bQsTdJ8+OGH1Yc\/\/GFlWpamrFQ9byff9LxziE586R1W3zTrznpHyiaVK6IfVp2oYaHXHp1Zi1YHRZpAHHs7zz33nPrKV76ib+e47bbb1A033NC6lw7K7LOf\/WwtBsemkVd7sy3nITvarZ60d1B21qxZGqOkctHv2bQztDKCUbRf+Hd5ylycoU4hTMx7uS0DlmWapYnbbD75yU\/qJiNISN4NkTTRxywSRJk4orMlxWg5kqa95JM07bFyWhKJxxHUgFX0pz\/9afXQQw\/pTBvvfOc7dT1VWQBOO2l8zEa5RS3DtHdQ9pVXXlE333xz4l4nLU3VwihpXMueZ0l7ktjfTNrTfPLJJ9XTTz+tPvOZz+hF5nvf+16diQYyZDOviprTScRVZH1x3zYJMI38SJRuRoak6QbHjr5ihtEj+OFDH\/pQKyIwNEuzI4AyXkLau9GjRxfx6WC+mYRRFZZmWhBP9DfTBfvII4+0kebSpUvV3XffrUlTFpj4f5meGRvPSbeTKM5TYlOvvJdVlp6YwSOUJS9le2W6mUPBuWdNMKL7OVw9dzNV+G4nCJSxeo6mLJR2RpPv44Ya85wmCNR0z77rXe9Sb3zjG9u2MspWZmXJaB7vi+Ap72S1kZ6YwZIi3qs4GSrbK9OJHJvvBEmasrrGhclYTeN8Gp6syd4tmFnvh7a\/8fqnl2d1Oejfv\/ruvZn9K4M0MxsRUyDOOvUhetY2wrWTPpvvRKNaberNipSV7zNiNv\/olL04y9\/Cr78RJGlK96KKgaTZzVQZ\/C5Is06T3WXvsTquM2kCC5Bk2pETl3j58C1T\/tMszazzm3HfSfs2+l43a8rleIXW96BJUxQD\/i\/RhC4nQ9O\/FZow5BnPEPqOvf8mJTfIM76uy4YwXzrFJLS+B0WaYlnKOU0zM4okN+h04PneYARCE4Y8YxxC35lGL8+Id1c2hPnSKQKh9T0o0sSgmsmp8XfZ0zSDJapOrdfp5HP9XjSAxNz\/TUvyLe0ITRjy4Ct9t8Epz3fLLpuUsJ3yMngkupEXykp\/m26OXhxQ9rzvpr7gSDMODNPivOWWW\/TNJyHn2LSZEJKnF8cMcCzHTK+G4yYmRtEAEZekadZrJgo3vQavvvpqy41o07cyykAJnj592gqnMtrjsg7Ky2A0u5UXF6RJWXE5yzv\/ViNIM5oVBavr48eP6\/y0uD6Mz9ezyWAxMXv27MQD8UjFRtK8Fthx4sQJK5zqNr8oL9kjZgYZ2shL00kzJFlpBGli72b\/\/v0tkoye38wWkfBLmNbFyJEjE1OvmdZgliIY8cALLeCSjl5EV8+wapGpBte74YEr3bQ0TRcZvAZVXZyNvh85csQKp7rNHspL9ojllRfKSjiy0gjSjFqWJM3BSiHpnsXozRhFkibSH6IdIEL8GSnddu7c2SLNFStWtFl2ZvRntppzWwJKEMkDpL1pOLmtufivUV6yMc4rL65Jk7KSPUZFlWgEaXLlnD59oAAuXLjQssTTknwXSZq4qgqPeb8jIqHF0lywYIEmUrRVnqqsTVqaRakk\/7\/biby4Jk3KSnXzpBGkyT2a5AkWF+STluS7yD1NG0Vg3thRndhc29M8duyY2rBhQ+wFzyZOVbazk7opL+7lJYs0bcYpehdq1gKTsmKDav4yjSBNRgPGT4ykqNi0JN\/ml1wrAhuX0\/Lly9WiRYt0asQqA7oYPZtf2dT9jW7khbISTqR5I0gTwspzZ+0qK3qeVX6Vs5o25w9dKwK4fusUCIQUgjY41ZEsKC9u5YWyEo6sNIY066i4fG+zC0Xgex+T2tfkvtd1zKpsd5PnS2h9J2lWKUk1rzs0YcgzHE3uex6cWPYaAk2eL6H1naRJqe4YgdCEIQ8QTe57HpxYlqQZmqyQNCnVHSMQmjDkAaLJfc+DE8uSNEOTFZImpbpjBFwIQzQJtjQGiQNwMw3O2C5ZsqStjZLs+dChQ2rdunVtF42jIIKJcAH5vn37dF5deeKiH6N3StqC4aLvtnWxXP0RcDFfKCt+zAOSph\/j0HUr4shFPooEACtXrlS7d+92mnbOlSLo7e1VO3bsaBGceZTk5MmTbVl3zOMw6N+BAwfUrFmz1KpVq3R3JZp1YGCApNn1rAr3A2XLC2WlP5jJRNIMZii\/3pG4NIFFpA4sShGYh+vPnj3bRpropaTP6+npUadOnVLDhg1TSLGHhAKS\/eny5cutpAM2lqYk3Z4+fbravHmzGjVq1CDSNaeKi74HOPVq2aUy5MXFfIm75YSyUv6UI2mWj3nhNRZBkHGNzlIE\/XcOab02tu9qbL\/jFEEeS\/PcuXP6u0jwDncu3K0TJ05UfX19uUkTiRPwDaTxy0qckNX3wgeZFThDoAx5yZovlBVnw1n4h0iahUNcfgVZK+c9e\/aoK1eu6P+w9wf3LRKjr127VsEdGs3nKgkH0BPzAm9XiiCaT9a08rL2NEGaIMyjR49qa3PTpk1q9erVasuWLblJc82aNa13oqnkoqOY1ffyR501dopAGfKSNV9sSZOy0ukou3uPpOkOS2++ZKMEJFBGLpw+f\/683u\/Ek5SqDr+Zl1O7UgTmnmaeGzbETStkOWfOHO2ujd6GIgMTdyuKBAJF70QkaXoznQtvSBnygoA1ZJBKemxJk7JS+HTIrICkmQlR\/QrYKAH0Cm5IPGZUqRloM3\/+fE2SuGkEbks85o0xEyZMSFUENsjFuWfTrl0yv2mSIN45c+aMmjt37qBLtOWdKC4SjQgre\/z48YmLhbiLyrMWDDZ9Zxk\/EChDXrBITSNNGyQoKzYoFV+GpFk8xqXX4EoJwPqC1QmXrfmI+3by5MmFKAKJgAVRw\/Vq3lmZRJroM9zLOGaCS7RNV2v0Haz65Ynm2h0+fLi+vYSBQKVP28oqLENeIENFkCZlpfxpQ9IsH\/PCa3SlBOIsTbPxIVlb5k04YlWnDVRIfS98QnpeQRnyEtJ8abqskDQ9F+hOmudKCcRdv2VewOvCPdtJ\/4p4p+mKoAhM6\/LNMuTFhXvWFzybLiskTV9mosN2uFQCaJYZPWtG1oa0es4Lf5P7nhcr38uXIS8utjJ8xzGpfaHJCkmzrjPRg3aHJgx5IG1y3\/PgxLLXEGjyfAmt7yRNSnXHCEAYmvx0G9jRZOya1nfKCtPoNW3Os78ZCJjJpCXZetwrkqwgKzqVgBOBkBGgvNR3dGlp1nfs2HIiQASIABEoGQGSZsmAszoiQASIABGoLwIkzfqOHVtOBIgAESACJSNA0iwZcFZHBIgAESAC9UWApFnfsUttOfKymunipHD0BpMiup90w3wZdRfRH34zfASqlBegKwkDJGXlvHnz1Pbt21Vc3uPwR8PvHpI0\/R6fjlsnSsCMZBUymzRpkpVAQpBxjRiu2upGeKUtkue1407xRSJQEAJVywsSiMjNQ5cuXVJLlixRlJeCBrvLz5I0uwTQ19fjlIDcYCLXgI0YMSKx+bLyHTNmjBXBJn3I1Xd8xZntCgOBKuVF5BJIwrrE33FRQreyF8bI+NcLkqZ\/Y+KkRWkrZ7h+YD3i2i+TQMUSveOOO9TFixf1yhePeabSTKln40KKa4eTDvIjRMAhAlXLCy1Nh4NZ8KdImgUDXNXnbfZoJNGAuHBNxSH3S5qrXVOwcf0WVsO4EUTu5Yz2NY9lWxVOrJcIAAEf5MVsA12z\/s5Lkqa\/Y9NVy+JWzuIqHRgYaN07KcQXtTxRuekiinMZgURBvHv37lVxrl6xXGGRJhFrV53ky0TAEQJVy4spS9jTXLZsmaLcOBpcx58haToG1JfPJblFo\/8uwgpSwyXOIqjRvUghzeiF1Gnp8Oia9WU2sB1ZCFQpL+ZF0pBDemiyRqva30ma1eJfWO22SkBctNOmTVPHjh1T4qpNIs08wQmmO3fcuHGF9ZUfJgLdIlClvJA0ux29ct8naZaLd2m12UYDmufDzHOU0Yg+HDmJ29NMIlGulksbalbkAIEq5UVk5aWXXtLbJnjonnUwqAV9gqRZELBVfzYpsCHOnSoRsffee2\/b3qP5DbFAky6kjvaXR02qngGsPw8CVcuLEKdErEdlMU9fWLZYBGpPmqKcsReASE7TcuL1U3aTR4gw7Uovuy+xFBEIHwHKS\/hjnNbD2pNmdALj7zNmzNAEiv06\/D0purPZQ3+t97LIwJ+JE2cEEUhHgPLCGVJr0gQp7t+\/Xx\/QF0vTHFJM8DVr1qj169crBqIMnuwSBIRfaGU2UxnEueCbiUR2rykv2Rg1oURtSVMIEb5\/WJNxpElLswlTmH3sFAFTPnA2sLe3V+3YsYMLzE4B5XuNQKC2pIkVMp7Zs2frQ\/gmaZqb6tHMGmPHjm3EwLKT1SLQ399fbQMsaocMnTt3TsuOyMzUqVPVwoUL9duUFQsQWaRrBOogK2Yna0mayDTz0Y9+VD300EPqwoULav78+doNe88997T6Bkv0\/vvvV6973evUnDlz2hRB3Qap61mZ8wNQlsQoHbQsjLJ+zzkkhRSHh6anp6clG\/g7HsneVIc+FAJMjo8SIzuw0nCqG4a1JM2k8PDowXyki7vtttvUDTfcoBVB\/51D7EaYpVIRmHzT80TIEoHXHp1pWbLcYnGWpUmalBU340FZscfRV1mJ9qCWpCmdwJ7MRz7yEZ3JBpbm4sWL1fve9z71hS98QT388MPqYx\/7mI4O3bhxo46mpSKwn8BpJakI7HH0WRGkWZqUFfsxpqy4wcpnWam9exYdkEAgEOX73\/\/+lns2egM6XLRIRo6HisDN5CZp2uPosyJI29OkrNiPMUnTDVY+y0oQpJkWCGSSavS4CYMb3ExwfiUbAd\/3hbOiZykr2WPMEm4Q8F1Wak+aZiCQ3L4RPXLCM5puJnPaV5quVOsk6EnjyHOaxcsJaqCs+B9NbjsTarmnmRUIlGZp2gLDctkI1C3qLbtH9iWa3Hd7lFhSEGjyfAmt77UkTVMUo7ln5TdamsUrrNCEIQ9iTe57HpxY9hoCTZ4vofW9MaQJly6u28G5Tt4gcE2QTUzwdzMRhBlQhYupt2\/frnA9mPmEJgx5FLz03QanPN\/1pSzlZfBIdCMvlJX+tss0knSKL\/M\/rR21J00bkE1rFHdGPvjgg8rMfGLzjdDKYC9469ataunSpTptGhSCpFEbPXp0G0bRQ+90OV2zHE6fPm2FU93mDuVl8Ih1Ky9NJ82QZKURpAlC2LZtm9q1a5caMWKEwp7o8ePHY62nuik4V+01D7sjNaGZ6D4ph68LRWCStZlUX9qDI0WvvvpqK92bq\/52+x30\/cSJE1Y4dVtX2e9TXrIRzysvlJVwZKURpCm3oYiLkYncBysF07oYOXJk2yIjidiargiOHDlihVO2CvarBOUlezzyygtlJRxZaQRpRi1LkuZgpWC6YKP4lEmacj8q7kTFg\/1n09I095Xgaq\/qDlAoQaRtNO9rTcIpWwX7VYLykj0eeeWlCNKkrGSPUxElGkGaXDmnTx0IHwKkxBKPuuc6Jc0RD7zQqjgp24f5bVxPJSSEPyNwa+fOnS3SXLFiRZs71MxoU4RwpH0TSpCWZtmo+1FfJ\/KSRZqUFT\/G1qYVjSBN7tEkT4W4IJ\/ocZ1O9zTzKoKDBw\/qhppXVZl7mgsWLGhFQEuPqrI2oQSR83jDhg2tS85D8WBQXtzLi2vSpKzY0FsxZRpBmowGjJ88SVGx0RswOo2eLYI0zYCuYkTC7quMnrXDKaRS3chLFaRJWSlm9jWCNAEdz521T6BoYnv5Vc5q2pw\/zFIENlM2r3sWF44vWrRI3wFZZRQ0z2najG44ZbqVF8oKz2mGIw3sSccIuFYEOHJSp+CGEHLPdjz4fDEXApQV5p7NNWFYOEwEXCiCuiLT5L7XdcyqbHeT50tofW+Me7ZKgQm17tCEIc84NbnveXBi2WsINHm+hNZ3kialumMEQhOGPEA0ue95cGJZkmZoskLSpFR3jEBowpAHiCb3PQ9OLEvSDE1WSJqBSDXOCC5ZsiS2NzjLuHLlSrV7926nGXRCE4Y8U6HJfc+Dk69ly5aXJs+X0PpO0vRVqrtoV9wh+yIO3rsQhuh1S9JtpKibMmWKilNucq3QoUOH1Lp169quNMP7iMA9fPiw2rdvn77BRZ64c3b4t56eHn2EJc\/jou956mPZ4hAoQ15czBfKSnFzIM+XSZp50KpJ2SIIMq7rrhSBXEkmBGeevzx58mRbflcz8QLadODAATVr1iy1atUq3UQ5TzcwMEDSrMl8rbqZZcgLZYVHTqqe56w\/BYGslfOePXvUlStX9H+wyOC+RY7XtWvXKpBUNDWdnJ1EleYF3lmKoP\/OIa1Wju27GtviuLy2Zhq3s2fPtpEmPiI5Z2Ehnjp1Sg0bNkwhLy2ufZM8w5cvX26lt7OxNOU6tJr6FTIAAAOASURBVOnTp6vNmzerUaNGDSJdswNZfecErQ8CZchL1nyhrNRnvtDSrM9YWbfURgmI+1IunD5\/\/rze78STlHUHv5kXeBelCPJYmufOndNtxq0ocOeC4CdOnKj6+vpykyb6jW8g921WtqGsvlsPFgtWjkAZ8oJthLRkGJ2SJmWl\/OlD0iwf88JrtFECaATIAY+512e6P+fPn69JEknTQSZ4zBtjJkyY4EQR4DYT3LIij2nlZe1pgjRBmEePHtXW5qZNm9Tq1avVli1bcpOmefF2NGl5dNBImoVP49IqKENesEh1QZqUldKmRWJFJM3qx8B5C1wpAbgsYX3BZWs+4r6dPHlyqiKw6VjUPZvnLkdx0wpZzpkzR7tro1eISTvirhKTQCBxz65fv14HD5E0bUYvjDJlyAtkqNu0i5QVP+YbSdOPcXDaCldKIM7SNBvqwtqK29NMu+DXrN8kQbxz5swZNXfuXBUlQHkn7nJtubNz\/PjxiW7poUOHDhofF313Ouj8WMcIlCEvLuYLZaXjIXb6IknTKZx+fMyVEoi7ScS8gDfLPWuDRpwikAhYuIThepWLqRHok0Sa6DMCmXDMZOTIkW2XVUffwf6SPNFbXYYPH67vyWQgkM3ohVGmDHnJcs\/aIElZsUGp+DIkzeIxLr0Gl0oAjTejZ83IWher59LBSajQvHNV9m\/T2hZS330Zg6raUYa8uNjKqAqfaL1NlxWSpi8zsYbtCIk4mq4Iajj9atVkygrPadZqwrKxxSAQkiLIi1CT+54XK5bnLSfdBkH5NIdoafo0GjVrC4ijyU9IiqDJ41hG3ykrtDTLmGesgwgQASJABIiAVwjQ0vRqONgYIkAEiAAR8BkBkqbPo8O2EQEiQASIgFcIkDS9Gg42hggQASJABHxGgKTp8+iwbUSACBABIuAVAiRNr4aDjSECRIAIEAGfESBp+jw6bBsRIAJEgAh4hQBJ06vhYGOIABEgAkTAZwRImj6PDttGBIgAESACXiFA0vRqONgYIkAEiAAR8BkBkqbPo8O2EQEiQASIgFcIkDS9Gg42hggQASJABHxGgKTp8+iwbUSACBABIuAVAiRNr4aDjSECRIAIEAGfESBp+jw6bBsRIAJEgAh4hQBJ06vhYGOIABEgAkTAZwRImj6PDttGBIgAESACXiFA0vRqONgYIkAEiAAR8BmB\/wNX6q9C9fPLjwAAAABJRU5ErkJggg==","height":251,"width":417}}
%---
%[output:393f2c47]
%   data: {"dataType":"text","outputData":{"text":"\n============================================================\n","truncated":false}}
%---
%[output:1fbc2485]
%   data: {"dataType":"text","outputData":{"text":"BYTE STATISTICS - CAN ID 0x121\n","truncated":false}}
%---
%[output:84b4ff45]
%   data: {"dataType":"text","outputData":{"text":"============================================================\n","truncated":false}}
%---
%[output:0d87b6f4]
%   data: {"dataType":"text","outputData":{"text":"    Byte      Idle Range    RPM-Up Range     Idle -> RPM\n","truncated":false}}
%---
%[output:5c398b57]
%   data: {"dataType":"text","outputData":{"text":"------------------------------------------------------------\n","truncated":false}}
%---
%[output:8413b9c3]
%   data: {"dataType":"text","outputData":{"text":"B1                     0               0               0\nB2                     0               0               0\nB3                     0               0               0\nB4                     0               0               0\nB5                     0               3               3\nB6                     0             255             255\nB7                     0               0               0\nB8                     0               0               0\n","truncated":false}}
%---
%[output:04e4051b]
%   data: {"dataType":"text","outputData":{"text":"\n============================================================\n","truncated":false}}
%---
%[output:5dcf0aed]
%   data: {"dataType":"text","outputData":{"text":"16-BIT SIGNAL TEST\n","truncated":false}}
%---
%[output:38101ce7]
%   data: {"dataType":"text","outputData":{"text":"============================================================\n","truncated":false}}
%---
%[output:174594fd]
%   data: {"dataType":"text","outputData":{"text":"\nB1-B2\n","truncated":false}}
%---
%[output:81378e54]
%   data: {"dataType":"text","outputData":{"text":" Little Endian: Idle = 56064.0 | RPM-Up = 56064.0 | Ratio = 1.000\n","truncated":false}}
%---
%[output:02c374d9]
%   data: {"dataType":"text","outputData":{"text":" Big Endian   : Idle = 219.0 | RPM-Up = 219.0 | Ratio = 1.000\n","truncated":false}}
%---
%[output:1f750aa8]
%   data: {"dataType":"text","outputData":{"text":"\nB2-B3\n","truncated":false}}
%---
%[output:8ebd23cf]
%   data: {"dataType":"text","outputData":{"text":"\nB3-B4\n","truncated":false}}
%---
%[output:138e1a06]
%   data: {"dataType":"text","outputData":{"text":" Big Endian   : Idle = 56283.0 | RPM-Up = 56283.0 | Ratio = 1.000\n","truncated":false}}
%---
%[output:3c5986f2]
%   data: {"dataType":"text","outputData":{"text":" Little Endian: Idle = 56283.0 | RPM-Up = 56283.0 | Ratio = 1.000\n","truncated":false}}
%---
%[output:275ae6a9]
%   data: {"dataType":"text","outputData":{"text":"\nB4-B5\n","truncated":false}}
%---
%[output:3bc62305]
%   data: {"dataType":"text","outputData":{"text":" Big Endian   : Idle = 56064.0 | RPM-Up = 56064.0 | Ratio = 1.000\n","truncated":false}}
%---
%[output:6b32377c]
%   data: {"dataType":"text","outputData":{"text":"\nB5-B6\n","truncated":false}}
%---
%[output:3ed9d275]
%   data: {"dataType":"text","outputData":{"text":" Little Endian: Idle = 219.0 | RPM-Up = 219.0 | Ratio = 1.000\n","truncated":false}}
%---
%[output:21045511]
%   data: {"dataType":"text","outputData":{"text":" Big Endian   : Idle = 3.0 | RPM-Up = 5.0 | Ratio = 1.667\n","truncated":false}}
%---
%[output:91f9edb6]
%   data: {"dataType":"text","outputData":{"text":"\nB6-B7\n","truncated":false}}
%---
%[output:9bea9e3c]
%   data: {"dataType":"text","outputData":{"text":"\nB7-B8\n","truncated":false}}
%---
%[output:7356fb4d]
%   data: {"dataType":"text","outputData":{"text":" Big Endian   : Idle = 950.0 | RPM-Up = 1518.0 | Ratio = 1.598\n","truncated":false}}
%---
%[output:7594ba97]
%   data: {"dataType":"text","outputData":{"text":" Little Endian: Idle = 768.0 | RPM-Up = 1280.0 | Ratio = 1.667\n","truncated":false}}
%---
%[output:729b50b3]
%   data: {"dataType":"text","outputData":{"text":" Little Endian: Idle = 46595.0 | RPM-Up = 46595.0 | Ratio = 1.000\n","truncated":false}}
%---
%[output:6b4ebc46]
%   data: {"dataType":"text","outputData":{"text":" Big Endian   : Idle = 46634.0 | RPM-Up = 46634.0 | Ratio = 1.000\n","truncated":false}}
%---
%[output:1ec776a1]
%   data: {"dataType":"text","outputData":{"text":" Little Endian: Idle = 10934.0 | RPM-Up = 10934.0 | Ratio = 1.000\n","truncated":false}}
%---
%[output:5f21e069]
%   data: {"dataType":"text","outputData":{"text":" Little Endian: Idle = 42.0 | RPM-Up = 42.0 | Ratio = 1.000\n","truncated":false}}
%---
%[output:3eb92419]
%   data: {"dataType":"text","outputData":{"text":" Big Endian   : Idle = 10752.0 | RPM-Up = 10752.0 | Ratio = 1.000\n","truncated":false}}
%---
%[output:7dcd2510]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAc0AAAEVCAYAAACCKL5fAAAAAXNSR0IArs4c6QAAIABJREFUeF7tXU9oX8e1niy1lfFG6LmOQd6U4lC\/hdAmfdUzhRZnV2RrY4RatEm9eFL1zzTBDbZkN84i0IUJqvFGtil0UdFs8tRXExDetFR0Z4HqGlWbEi9qiJd+zHXn19Fo7p0z586duXPvJwjE0pz5851vznfPzNy5b71+\/fq1wA8QAAJAAAgAASDgROAtiKYTIxQAAkAACAABIFAgANEEEYAAEAACQAAIEBGAaBKB4hZ79OiRePbsmVhaWuJWATsgAASAABBoCQIQzQYd8eTJEzE9PS3m5uZaI5p7e3tiZmZGHB4eDka+trYmpqamrEhI0V9ZWRHnzp0TGxsbYnh4+Eg5vb7NzU0xPj4++LuydY3\/1q1b4u7du4VdWTtUN6m6zL5Ie72dkZERce\/ePTE2Nnas6qo6qP1Q5RQGNjvbWG3lL168KNbX18XQ0JC1eX1cZgGb7atXr8Ty8rLY2toqilP9Y8NUtad4cP78+cq+2gYQAu8qDGSbVX2n+FRh9sc\/\/nHAmxD9prSNMu1CAKLZkD9evHghrl+\/Lr73ve+Jv\/zlL60QzaoAbguucgyzs7Nid3e3QMkWeHTRNOugiCZHJMpcph5SbH21BVWbcFbVwaFKFeayPhMzWz\/riKYpiqZP1ZiqHpwo4lAmmtL23XffPfIwZf6OUr8Le4imCyH8PRQCEE0CkjKQPnjw4NgTtB4Q9axBPpXeuHFDXLlyRXz11Vfi8ePHyUWzLCPUx2CKohIQmS3\/4Q9\/ELYswsxc9eDrEk0VwP\/xj38UT++jo6ODDMg3MzDFSbevasfWX0UJ3z7YqKT6ZYqS2SeZ8dqyGQI9Bxm02V\/lm5MnTw5WCUyfKB9XCTNH1PRsVvXL9js5Pk79Ji4h6qjCmusbiv9QJi8EIJoOf5UFFfl7OVHVkqUMRjs7O4WwHhwceC2BxqBMWfBWQev06dPHlmjl+OQSnhS03\/zmN4P\/15c09cAsxa8qQJvjtGUnZj\/Vv1VQl3WopUUlRKqMzBxl+zIz1gXE5sOydsrq4PrIJZqyXsUh29K5KWY2zMoEo6ys8qltado2Toog6W198MEH4uc\/\/\/lg+VfW+YMf\/KCo+ne\/+92gCTW2Tz\/9tFiet\/mMkgn7CK\/uD3nWQG0LmDibS9g\/+9nPxJ\/\/\/GfhWp41M179YVo9KMn+yjMOCwsLg22SEA9oXI7Czg+B3oqmJLAMHjIbVD+S8Eo89EzgO9\/5jnj58uUg01QTamJiYiA0svz8\/LxYXV09sk8mA3YbMk1K4NOpo8Z\/6tSpYtxSiGz7s3qwfOedd8RHH3002CNzZZq2PV\/zd3rwkiIpf+Qeqx7k1GGrq1evkjJVW9bgWwd1mrmWZ6uEQrWh7zlWiaatT\/oStBr38+fPxeTkpPjkk08Kk9B7mnVFU18i18dEWUK2YaALV5U\/VP2mYOp16niac6qsboVv2dK4rL\/uXj6VjyhXH4HeiqaaGHISyKc+85SrJLh8svzud79b\/E1lkfIwhiK\/tFMHX2xCKt3TBtEsWxaroo+ZIekBVz8QpAfxDz\/8sNjHVU\/jf\/rTnwqBKwvKFNGUfTQzsLJDPNRxqmBn6xe1DurUc4mmPhbzIUONW7ZVdmhJz7LK+qQCsuSufgBIL18lnJQHLlPMZd2qLZ\/lWdlX007P0GyH0VwY2ERT\/53JBxvuiqtVomnib65wSG6pMwJKoKk+pvIN5ZpHoLeiKaHVn\/yq9nRsomnLKvVMtXnX0VvwFYKqJ23Zqp4dmcFSZaQSTzPzLAsqesAuO3Fctfeq6qWMUwXIMn9T6lAPQzLzVj9l9ZUtz5oZtO30MrUvZaKm81v6TBckn6AdUzTPnj175PBZWZZnconSR2ljW\/0wOWfjoM\/pWTNTVtxQoqn28OvsY9NnP0qGRqDXoqmymJs3b4o7d+4ce51CgZ27aJYFCzU+U+xte2s68XSBoCwXlmUxlD1NvY9q\/6msPpfIuARTtuWqQ\/WnLDCar4VU7SXrAdy2tEztS5VgqL8pkdT3qalBmyJIoTLNWKKpL\/WGEk3T12WZpuSQyphxwCi0pDVfX69Fs06mKZdZKMuzzbuQ1kLZ6VnbKxau7Eg\/DGETPnPvpkzkqKdnbXtctoMTVSKjxuTaO6IKFQ31f2c25n6cLdM0Dz2pA2X64Spbu9RMU24lmL61nbDlZHHUA0q2vuq\/sy3PUrCmCLv+8FglmpzlWSX2ehZp+lNlmhBNikfbW6a3ouna09RdZmaaPgeB2uT6qv21qiUkEwt9n7Ls\/Ty9Lcp+WVkmay4xynJyWdQmfmWCV5U5V4lZiBONPnualHcoKZm9yTnbCU717q0q6+sjZafqlq9WyUsz9NeS9JOk5klZaV92erbsIBDltZiy+abGZ3sgrDp8ZtZXtqepi71pY84tiGaboqJ\/X3ormjL4yP++\/\/3vD1Ar25M0RVMaVL1yUnZzi797wlvYBMT21F0WoMzMxBYsZa91AaOezpR2phjaDu2UncotE03KiUmFdFOZps2TtgNNpn9MUfcVTdvDBXUlQPXZfI1CH0uVaOrip8o9ffq0eOjRff3ZZ585XzkJdcEDRTRN\/sp\/U1450X0nffvLX\/5S\/OpXvxocjDtx4kSxXwvRDB\/XYtbYW9H0AdkmmtJeD8auZT+f9lAWCAABIAAE2olA1qJZ9d5T1Ttd7XQFegUEgAAQAAJtRyBr0bSBK7O\/hw8fWi8Xb7sz0D8gAASAABBoNwKdEk21p\/Dxxx8fuSC63S5A74AAEAACQCAXBDolmvLAgvzBtytzoR\/6CQSAABDIC4HOiKbMMhcXF8Xt27et30jMyy3oLRAAAkAACLQRgc6IZtkJVxP0M2fOtNEP6BMQAAJAoLcI7O\/vZzP2Tohm2WXpNi9I0czJQTGZBGyq0QY+5fgAG3CHG6ty404nRNNnaTY3B3GJyLEDNgh8HN5IG3AH3OkLdzohmubtPFXOw+RGttCXyc0dJ8cO8wqiyeFNjg9cnRBN6n5mjg7iEpFj99e\/\/lW8\/fbbHNNe2ACfcjcDm+opAHy687DeCdH0idh4Ikbg8+GLXhaBD9wBd7gIQDTDIxepRogmAh+XahBNcAfc4SIA0QyPXKQaIZoIfFyqQTTBHXCHiwBEMzxykWqEaCLwcakG0QR3wB0uAhDN8MhFqhGiicDHpRpEE9wBd7gIQDTDIxepRogmAh+XahBNcAfc4SIA0QyPXKQaIZoIfFyqQTTBHXCHiwBEMzxykWqEaCLwcakG0QR3wB0uAhDN8MhFqhGi2e\/At\/\/DtwYAnPn1ay\/WmaJZpy6vhjMojAeKaicBH4hmBtPY3kWIZjtFM5YA1WmnSjQlqr4inO0ksnQcogDR5PI5t5iMG4G4nu6gXcrAV0fMfFxRpx2IZjsfuHz8n6psyrmVaszUdiGaVKQSlcvNQTFhSjmx64iZD0Z12rHhU6c+n363vWxK7rQdG9k\/4IPl2Rx4au0jRLOd2UIs8anTDkSzndzJIRhBNCGaOfAUounppZQTu46Y+QyzTjsQTYimD9f0sinnFrfPsexyS2SwpxmLGRm0k3Jic8Qslo1yHUQTosmdxinnFrfPsewgmrGQZraTm4OYw2SZpZzYsQSQ0w5E002nlNxx9y59CeCD5dn0LGT2AKLZzmyBI2axbKiiKcv19bUTiEJ1QAI+EE2mZKU3g2h2RzQ5bNKF1lfkXMuzvvVx+t9WG4gCRJPLzdxiMvY0uZ7uoF3KwFdHzHxcUacdiGY7H7h8\/J+qbMq5lWrM1HYhmlSkEpXLzUExYUo5sTlixlmelXhy7crw4dYX07dNt5WSO02PLUT9wAfLsyF4lKQOiGY7s4VUoumzpEoRTZ\/6kkyAhhqFKGB5lkut3GJyJ5ZnHz16JFZWVgY+29zcFOPj41Yf5uYgLhE5dqkDn2\/G5lteYWIKtPq96xAPVTR17F11cvzURpvU3GkjJnqfgA8yzdZw9MmTJ2JhYUHcu3dPjI2Nib29PbG4uChu375d\/Nv8gWi2M9M0l019CeYjTmWieYwrxldQqgIfV4h9x9nW8hAFZJpcbuYWk7PONF+9eiWWl5fFxMSEmJqaIvksNweRBhWoUOrARxUz23B9RJMq0GadEM32PnAFmgKNVZN6bjU2sAAV5xaTsxZNV1ZpDa5nzoj9\/f0Aru5eFakndkzRdC3Vyr\/7iGb32OA3otTc8ett\/NLAB8uz8VlnaVGK5s2bN8Xc3FyxRHt4eChGRkYGS7Vloql+v7293YpxtKUTBwcHYnR0NGl3Xi+ecbb\/1u03Dz16WfU7p7GjQFWdbcCn7viasgc21cgCn+P4TE5ODn6ZUyKTfaY5MzMjzp8\/L9bX18XQ0JAw9zhNV+W2FNBUkLPVi6fh6tdRgE85G4FN9UwFPsg0Y8by0rZUpnnnzh0xPDxclHPtc0I0EfiqyFt1IheBD9zhBj5wB6LJ5U5QuxcvXoj5+Xmxuro6OCkL0eRDjImNbIHLHnAH3OFyJ7dEJuvlWekk+Y7mzs4Olme5jNXsEPgQ+Lg0AnfAHS53IJpc5GrY6ZcbUA4C5bTpXAMWb1MEPgQ+b9L8ywDcAXe43IFocpGLZJebgyLBUjSDwIfAx+UbuAPucLmTW0zOfnnW11G5Och3fHXKI\/Ah8HH5A+6AO1zu5BaTIZpcT3fQDoEPgY9La3AH3OFyB6LJRS6SXW4OigQLlmcJQEMYykECNhBNwhSyFsktJiPT5Hq6g3YIfAh8XFqDO+AOlzsQTS5ykexyc1AkWJBpEoCGMCDTJNDEWgTcKUcut5iMTJM7Czpoh4mNbIFLa3AH3OFyB6LJRS6SXW4OigQLMk0C0BAGZJoEmiDT9AQpt5iMTNPTwV0uDlFAtsDlN7gD7nC5A9HkIhfJLjcHRYIFmSYBaAgDMk0CTZBpeoKUW0xGpunp4C4XhyggW+DyG9wBd7jcgWhykYtkl5uDIsGCTJMANIQBmSaBJsg0PUHKLSYj0\/R0cJeLQxSQLXD5De6AO1zuQDS5yEWyy81BkWBBpkkAGsKATJNAE2SaniDlFpORaXo6uMvFIQrIFrj8BnfAHS53IJpc5CLZ5eagSLAg0yQADWFApkmgCTJNT5Byi8mtyDT1j0hvbm6Kv\/3tb2JnZ0esr6+LoaEhTxdUF8\/NQUEH76gMooBsgcs3cAfc4XInt5icXDRv3bolDg8PxeLionj\/\/ffF0tKSOHfunFheXhYjIyPFv0P+5OagkGN31YXAh8Dn4kjZ38EdcIfLndxiclLRfPHihZidnS2E8ezZs4P\/Hx8fF0+ePBFSUDc2NsTw8DDXH8fscnNQsIETKkLgQ+Aj0ATLjwyQMLfKQcstJkM0GROgqyaY2BBNLrfBHXCHyx2Ipidycj9T7l\/qy7Mq67x06ZKYmpryrLG6eG4OCjp4R2UIfAh8XL6BO+AOlzu5xeSkmaYCWS7FTk9PH8F8bW2NJJivXr0q9j+3trYG9nJPtGxZNzcHcYnIsUPgQ+Dj8EbagDvgDpc7ucXkVogmF2xpt7e3J+7fvy+uXbtGOmmbm4PqYONri8CHwOfLGVUe3AF3uNzJLSZnL5oyS338+DH5lG1uDuISkWOHwIfAx+ENMk03aphb5RjlFpOzF025J\/r555+LL7\/8svBK1dKs\/HtuDnJPx3AlMLEhmlw2gTvgDpc7ucXkpKKpXjnZ3d214u0SQGmk3vNUFyFIEX348GHlnqZqbHt7m+vnTtodHByI0dHRTo4txKCATzmKwKaaYcDnOD6Tk5ODX+7v74eYolHqSCqaZSOUYjo\/Py9WV1fF2NiYFxDqYNDExIT1IFFuTzVeg69ZGNkCsgUuhcAdcIfLndxicitFU4Iv9yofPHjAukpPZp+nT5+GaHqyGIEPgc+TMoPi4A64w+UORJOLnGFHuRFIv1FI3iIkf1SmefnyZaF+p1edm4MCwUmqBoEPgY9EFEshcAfc4XInt5jc2kzT3Kssc4htT7PqsvfcHMQlIscOgQ+Bj8MbaQPugDtc7uQWk5OKZtVBIHlZ+71790h7mlI47969W\/jMdXgoNwdxicixQ+BD4OPwBqLpRg1zqxyj3GJyUtF0Uy18idwcFB6B8hoxsSGaXL6BO+AOlzu5xWSIJtfTHbRD4EPg49Ia3AF3uNyBaDqQc72bqZu7llo5TsrNQZwxcm0Q+BD4wB0uAuAOF7ncYjIyTa6nO2gH0UTg49Ia3AF3uNyBaHKRi2C3\/8O3IrTSnib+8z9+357OoCdAAAjUQuDFJ\/9Vy76txhDNtnpGCAHRbLFz0DUgAAQqEYBotoMgyZdn5ae9ZmZmxOHh4TFEQu9pQjTbQTr0AggAAX8EIJr+mDVhkVQ09Xti33vvveJj0vImn7Nnz4rZ2dnic1+2W33qAJHbUkCdsfraYl8K+1K+nFHlwR1wh8ud3GJyUtE0r8HT74ytc\/dslfNycxCXiBw7BD4EPg5vpA24A+5wuZNbTG6VaMrPej179qzIMCl3z3KclJuDOGPk2iDwIfCBO1wEwB0ucrnF5KSiKUGW2aX8MYXyiy++EFV3yPbFQdxxcuwgmgh8HN4g03SjhrlVjhFE082fIyXM71+qe2R97p71aTI3B\/mMrW5ZTGyIJpdD4A64w+VObjE5eabJBZprl5uDuOPk2CHwIfBxeINM040a5hYyTTdLWloColnuGExsiCZ32oI74A6XO7nF5KSZpjo9e+nSJTE1NcXF3MsuNwd5Da5mYQQ+BD4uhcAdcIfLndxiclLRlCDLE7MrKysDvDc3N4O\/m6k7MzcHcYnIsUPgQ+Dj8AbLs27UMLewPOtmCaOE\/jFpHARiAFjTBBMbosmlELgD7nC5k1sikzzTLANaCqh8V3NjY0MMDw9z\/XHMLjcHBRs4oSIEPgQ+Ak2sRcAdcIfLndxicqtEU880Q987qxyam4O4ROTYIfAh8HF4g+VZN2qYW1iedbOEWCLGkqzeFYhmuWMwsSGaxGl7rBi4A+5wuZNbTE6aaZp3z3JB97HLzUE+Y6tbFoEPgY\/LIXAH3OFyJ7eYnFQ0uSCX2VFEODcHhcaoqj4EPgQ+Lt\/AHXCHy53cYnKnRFMt9Va9tpKbg7hE5Ngh8CHwcXiDPU03aphb2NN0syRyCfUpsefPn1d+hxOiiT1NLjUR+MAdcIeLAEQzPHI1apTLstevXxdXr14VCwsLEE0mlhAFZJpM6uB7mg7gMLcgmty5dcSuag\/S53ua8lYh+XPhwgUxOzvrFE3Vie3t7SDj6EolBwcHYnR0tCvDCT4O4FMOKbCpphvwOY7P5OTk4Jf7+\/vB52tTFSbd0wwhmnt7e+L+\/fvi2rVrQn5mjCKaOTmoKcfb6sXTMDJNLt\/AHXCHy53ctsySiKZ532wZ2HNzc0XWWPYjRfLGjRviypUrYmxsTOD0LJe2b+wQ+BD4uAwCd8AdLncgmh7IUUSuqjqZZc7MzIjDw8NjxdbW1qxfTsnNQR5w1i6KwIfAxyURuAPucLmTW0xOkmlywXXZUUQ4Nwe5xhzy7wh8CHxcPoE74A6XO7nFZIgm19MdtEPgQ+Dj0hrcAXe43IFoOpDTs8GzZ88WB3d2d3etVk1c2p6bg7hE5Ngh8CHwcXgjbcAdcIfLndxicqcyTYrTcnMQZUyhyiDwIfBxuQTugDtc7uQWkyGaXE930A6BD4GPS2twB9zhcgeiyUBOXmQwPT19xLLq\/lhGEwOT3BxUZ6y+tgh8CHy+nFHlwR1wh8ud3GJy8kxTvrP58OFDsbGxIYaHhwvc1b7npUuXrK+NcJ0j7XJzUJ2x+toi8CHw+XIGoklDDHOrHKfcYnJS0QxxIxCNsv8ulZuDfMdXpzwmNkSTyx9wB9zhcie3mAzR5Hq6g3YIfAh8XFqDO+AOlzsQTU\/kbBezUy4p8GxmUDw3B3HHybFD4EPg4\/BG2oA74A6XO7nF5OiZphLEsnczdeDxniaXhjw7BD4EPh5zIJou3DC3sKfp4khr\/57bU01MIDGxIZpcvoE74A6XO7nF5OiZJhfYUHa5OSjUuCn1IPAh8FF4YisD7oA7XO7kFpNbJZry9ZOdnR2xvr4uhoaGuD6otMvNQY2AUFIpAh8CH5dv4A64w+VObjEZosn1dAftEPgQ+Li0BnfAHS53IJpc5IQQyDRrgBfAFIEPgY9LI3AH3OFyB6LJRQ6iWQO5MKYIfAh8XCaBO+AOlzsQTS5ykexyc1AkWIpmEPgQ+Lh8A3fAHS53covJrdrT5ILuY5ebg3zGVrcsAh8CH5dD4A64w+VObjE5iWi+evVKLC8vFxjLk7LyR\/57a2trgPva2lrwy9pl5bk5iEtEjh0CHwIfhzdYpXCjhrlVjlFuMTmJaN66dUscHh4eEcyRkRGxtLRUIKtuDRofHx\/8zk1LWoncHEQbVZhSmNgQTS6TwB1wh8ud3GJydNE075Xd29sTi4uL4vbt22JsbGyAu+1OWq5TdLvcHBRizNQ6EPgQ+KhcMcuBO+AOlzu5xeTooqmWZicmJorlVymi8\/PzYnV1lS2a8lWVlZWVwmcXL16svBwhNwdxicixQ+BD4OPwBsuzbtQwt7A862ZJRQmZRU5PTwu1b2m+n+nzEWrzI9Zy6Vf+qKVesxsQzXLHYGJDNLkTG9wBd7jcyS0mR880FbAq49QP\/6i\/Ub9uYmat0t61rJubg7hE5Ngh8CHwcXiDTNONGuYWMk03SxKVQKbJBx4TG6LJZQ+4A+5wuZNbIpMs0+QCXGan9jVdWWpuDgqNU1V9CHwIfFy+gTvgDpc7ucXkzoimcljZaVz1d+kg9bO9vc31cyftDg4OxOjoaCfHFmJQwKccRWBTzTDgcxyfycnJwS\/39\/dDTNEodXRONG37nDqSuT3VRGHBvxpBtoBsgcs3cAfc4XInt5gcXTTVydjd3V0nxq6lVvOdT1khRNMJa2kBBD4EPi57wB1wh8sdiCYROfNVEaLZsWLm6yquenNzEBcXjh0CHwIfhzfSBtwBd7jcyS0mR880dWD16\/SGhoa4mAtZz927dwt7V3aam4PYoDAMEfgQ+Bi0KUzAHXCHy53cYnJS0eSCXMcuNwfVGauvLQIfAp8vZ1R5cAfc4XInt5gM0eR6uoN2CHwIfFxagzvgDpc7EE0ucpHscnNQJFiwxEYAGsJQDhKwgWgSppC1SG4xGZkm19MdtEPgQ+Dj0hrcAXe43IFocpGLZJebgyLBgkyTADSEAZkmgSbWIuBOOXK5xWRkmtxZ0EE7TGxkC1xagzvgDpc7EE0ucpHscnNQJFiQaRKAhjAg0yTQBJmmJ0i5xeSkmaZ+O9Dm5qYYHx\/3hNu\/eG4O8h8h3wKigGyBy56+cke\/y5qLXdftXPfK5haTk4qmJEvZdzVdlxRwiZabg7jj5Nj1NfBRsQI+yDRNBBBPqmcPBR9KGeocjVEuuWjaBqmE9Pnz52JjY0MMDw8HwyI3BwUbOKEiiAIyTQJNsPyoIYB4AtHkzpkgdk+ePBHT09NFXWtra2JqaipIvXolIDmyBS6p8FAB7jSZabo+NiHjo7wyVCYSn332WdGVpaUlLp2j2FHiLaVMlM4SG0meaerLs00tyUI0aWyAKCDTpDHleKm+cidkwIdoctkX1y6paNo+7dX08EOSvOm+xq6\/r4GPijPwQaaJTJM6W96Uo8RbShm\/VpstnVQ01dDUV0ouXrwo1tfXRZ0vnrjgys1BrvGE\/DtEAZkml0995U7IeGLLNPUvOM3NzQm5RGtbnjXLtWXZloIPpQyXl03YtUI01cD29vbEzMyMODw8FE29gpKbg5pwelmdfQ18VIyBDzLNmJmmvocpE4nl5WWhDkfqe5r6N4Vl\/2S5iYmJRs6EUOeKKkeJt5Qyvu02Wb5VoqkPVD45qacqnJ5tkgL\/rhuigEyTy7S+cocS8If\/5\/8GsL745L9KITYzTRkD5Y\/KGm0Hga5evVqI5OXLlwfvuctyDx48aHzVjsIVCj6UMpS2YpVJLpp6dmkOuokTtLk5KBYRZDt9DXxUjIEPMk1OpskRzffee+9Yxihj5c2bN8WdO3cGp2d\/\/OMfi9nZWbG7u3ukazEOVVLmDSXeUspQ2opVJqlo6jcCNSGQNhBzc1AsIkA03UhDNCGasURTvm7HzTTdTI5XghJvKWXi9djdUlLRdHcvfIncHBQeAQQ+LqYQTXCHI5pUvpnLs3KZdWFhQdy7d0+MjY0VImo7CKTvacq9T1lOngtp+lAlZVyUeEspQ2krVpnkolm1PNvEEkNuDopFBGSabqQhmhDNmKIp25KCuLKyUjQrL375+9\/\/fmR5Vu136qdnm4ib7tlhL0GJt5Qy3PabsEsqmvqTlVrDlxvaZ8+eLdbpJSFCX+Kem4OacHpZnRCFarSBD0SzSdGMOddjtUWJt5QysfpLaSepaJqXG8inpdOnTxdHpX1OgPk8ZeXmIIoTQ5WBKEA0uVzqK3cQT6oZQ8GHUobLyybsWiWacini2bNnRYapH6+ueuXEXL831\/fxZEinTV8DHxUh4INME\/GEOlvelKMIIqWMX6vNlk4qmnJo+gkxXSi\/+OILsbOzU7mZbbuGT\/5ufn5erK6uFpvnIDmdQBAFZJp0thwt2Vfu5Bbwuf7l2lHwoZThtt+EXXLRtL3Qe\/fuXTEyMjI4NeYzcHmwaHFxUdy+fRui6QMc3tN0otVXYXAC02Pu5BbwKb4MWYaCD6VMyD7VrSu5aNYdgGlvvtuETJOOMEQBmSadLcg0qcuPVEz199ZNG3WtaFkZ\/d5udeLWfPdd\/6KU7ZrSsq0t15ZX1fgogkgpQ8UwRrlWi+bvf\/978c4775A\/Qk25ek86SP1sb2\/HwDibNg4ODsTo6Gg2\/Y3dUeBTjnhfsZmcnBT7+\/tBqFj21ScpWg8fPiwuapc\/5psFSgzl6pw8D6LKf\/Ob3xTXrl0bfADDdbd3U6JZFmclduonFIZBHOGoJJloVt3Kr8hPmFNlAAAQ7klEQVQj+y6JQrl7liKYoZ8MYzgoZhvINJFpcvnWV+6EzJLKRFP\/fdnreLbzIP\/85z+PnO1QbyTIS99tr\/M1JZouQQyJIZe\/PnZJRFN\/clK396tb+aVj5Uu88ofypRP1lCXLU27AyM1BPs6sW7bLgW\/\/h28N4Dnz69csqLqMDwsQzaiv2ISMJyFFU76FIH\/UK3zy\/2Vi8a1vfau4t5Yrmp9++ql4+fJl8d\/W1pZwXaRAwYdSpi4\/Q9pHF03bN+PUE5Bciv3oo4+Ez3c1fa+Mys1BIZ3tqqvLgS+0aIaoz+WPnP7eZe5U+YEST6hcCbk8K0Xz3XffFY8fPy4EUtZ9\/fp1Ib+KIq\/mqyOa8qCmSmhc8ZeCD6VMm+ZCdNG0EUNfa\/e5uL3qCr6yLDU3B8UkS5cDHzVwVeGt4xOivpi+bbqtLnMntmiaXyzR3ySgHgSSoim\/gCKF8sMPPxRPnz4tPhcm3yx4\/\/33a4mmfq9tiLcVcovJrRLNn\/zkJ41\/ODU3BzUd7PT6uxr4dIGT4w2xPAvRPMrMrnLHNf8o8YTKFTOhMA\/4yL6UZaN6P9UlMfq3NmXGKZdqL1y4UHpFadmFMvpep1yelT\/qztsQ78VTMHT5IebfWyOaVe9WhgQkNweFHLurrq4GPoimy\/P1\/95V7riQCRlPyi5rkadlL126VCQUPqKpTtLKS2LUoaATJ054i6b+Gp+5HItM08WQAH8vW56FaAYAt2YVXQ18EM2axCCYd5U7rqE3LZqyff0TYVWip\/qqX0eqtrDOnz9fHJSU2WvZxzBUbJYfyVCZpLL\/+OOPi49nSNGUB4D0z5VVfYaMgg+ljMsPMf+OTDMm2i1vq6uBD6LZPPG6yh0XciEDflkWqZZp5asiv\/jFL8RPf\/rTyi9A6aJpHrx0Zaq2PVP9fIjKNGVf5N4rTs+6GBLg71W3XpjVuxzC6U5IknPab7NNisBH3e+pgxtEsw56NNsU3KH1rNlSfYsnrhvXTLQp+FDKNOtFv9qjZ5p+3QtfOjcHhUegvMYUgS+2aHIPAUnUcHq2XdyJOTfK2upbPIFoCgHRbMPMa0kfbKJpZmlVXfUVpFAZoAu+UO1ANCGanEzKxc+c\/g7RhGjmxNfG+2qKpo9glj6JV9y+E0LMKJmqTztVZRU+PvU17rSWNJBilaINQ+9bpumLOQUfShnfdpssj0yzSXQzq7sJ0ZQQlGWgIcSHUgeljHIVRJNH2j6LJg+x\/ljh7tnMfZ3bUw0HbqpImOXeur0v3n777aJJW5ZpEz9KNtom0XQtIUM0OYw7ut\/Lq6HbVn19qKB4NbeYjEyT4tXMyoQUPDV0l9joELnaLxNanzbKMkNbZkt9iHA9LNiWZzl9zoxOpO5CFKphAj7l+EA0SVMsXaHcHMRBiipKlCyRI5ou8aH2jzr2MpHmtFNlgz3Nco9AFCCa1PlqlsstJiPT5Hq6pXY+QkgdAieb4vSD006ZQFeNraqdmP2m4p9DOYgmRJPLU4gmF7lIdrk5yBcWTtAva4MrYlVLp67xcNukjptaP7U+23Kwa4xd\/DtEE6LJ5XVuMRmZJtfTLbXzCfb6EKSYNBH4XP2R7VJeG7HBbdq52vJdag5dX0spE6RbTXAnSMdaUgnwKXcERLMlJC3Nns6cEa4j0C0fQmPdSzWxQ4lmFTDcNvQ6cblBOcKpuNPYZAhcMfCBaAamVLzqcnuqiYdMutcGuILmY+dTtgxziCZEkzsfIZoQTS53kttBNNsX+EIImotYIdpA4Gsfd1x+b8vfwR2IZlu46N0PiGb7Al8IQXMRIUQbyDTbxx2X39vyd4gmRLMtXPTuB0SzfYEvhKC5iBCiDYhm+7jj8ntb\/g7RhGi2hYve\/YBoti\/whRA0byIwDCCa7eMOw41JTCCaEM0kxHM1qn+xvKwsRLN9gS+GaIZoA4GvfdxxxYS2\/B3cgWi2hYuDfkjBXFlZEXNzc2Jpaam0fxDN9gW+EILmImSINpBpto87Lr+35e8QTYhmW7go9vb2xMzMjDh58qQ4deqUGBkZgWgyvZNqYocQNNeQQ7QB0YRounhW9vdUc4vb35h2uSUy2d8IJEXz66+\/FufOnROUr4rn5qCY5E01sUMImgunEG1ANCGaLp5BNP0Ryi0mZy+auosgmv6E1S0gmtX4QTQhmtwZlmpucfsb0w6iGRNtoy2qaCqz7e3thL1tX9MHBwdidHQ0esdeL54ZtCk\/hN3ET4g2dHxC1NfEOFPVmYo7qcbr2y7wOY7Y5OTk4Jc5XW2KTNOX\/R0un+ppOMTSqcstIdpApolM08UzLM\/6I4RM0x+zYBbUTDOnp5pg4BAqSiWahK7VLgLRrA1hZQVd5k4I5IBPOYoQzRAMY9YB0WQC9y+zVBM7hKBRRl63HWSayDQpPLOVSTW3uP2NaQfRjIm20RZEsx74qSZ2XTGjjrpuOxBNiCaVa2a5VHOL29+YdhDNmGgz2srNQYwhsk1STey6YkYdcN12IJoQTSrXIJp0pHKLyZ06CERxU24OoowpVBmIZjWSEE2IJneupZpb3P7GtMstJkM0Y7Kj5W2lmth1M0AqrHXbgWhCNKlcQ6ZJRwqiSccqScncHBQTJIgmMk0u31Jxh9vf2HbApxzx3GIyMs3Ys6fF7aWa2HUzQCqkddtBpolMk8o1ZJp0pCCadKySlMzNQTFBgmgi0+TyLRV3uP2NbQd8kGnG5lyw9iCa7csWuBmgr51v+apsQa9Lljvz69fBOJpjRRAF+gNXjv5tss+5xWQszzbJhszqThX4uGLma+db3rXEVre+zOhR2d1U3MkFQ+CDTDMXrh7rZ25PNTGBTjWxueLja+dbHqJJZ18q7tB7mLYk8IFopmVgjdYhmt1ZnvWlAUTTFzF6eYgClmfpbDlaMreYjOVZrqc7aJcq8NUVM6or6rZj4lO3Pmq\/cyiXijs5YCP7CHyQaebCVSzPengq1cSOJT5124Fotm+VwoPeSYummltJB01sHJkmEahUxXJzUEycUk3sumJGxahuOxBNiCaVa2a5VHOL29+YdrnFZCzPxmRHy9tKNbHrihkV1rrtQDQhmlSuQTTpSEE06VglKZmbg2KCBNGsRhuiCdHkzsdUc4vb35h2ucVkZJox2dHytlJN7LoZIBXWuu1ANCGaVK4h06QjBdGkY5WkZG4OigkSRBOZJpdvqbjD7W9sO+BTjnhuMRmZZuzZ0+L2Uk3suhkgFdK67SDTRKZJ5RoyTTpSEE06VklK5uagmCBBNJFpcvmWijvc\/sa2Az7INGNzLlh7EM32ZQt1M0AqOeq2g0yzfdyh+j51OYgmRDM1B9ntQzTbGfjqChqFEJQ2qspANNvJHYrvU5eBaEI0U3PwSPuPHj0SKysrxe\/OnTsnNjY2xPDwsLWPEM12Bj6KoNUlHaUNiCYPZYiC39I+D+VuWuUWk7M\/CPTkyRNx69atgVBKAd3Z2RHr6+tiaGjoGMtyc1DMaZIy8FEErS4WlDYgmjyUU3KH1+O4VsAHmWZcxpW09urVK7G8vCwmJibE1NRUUerFixdifn5erK6uirGxMYimh6dSPlBQBM1jKNaiddsw8albX93xtMk+JXfahENZX4APRLMVPJUCOTs7K5aWlsT4+HjRJ5uQ6p0FedtJ3hgCpLchUTjz69dePIZotpM7Xk5MVBhxpzvcyXp5tiyrlMu1p0+fHmSfpmgmmjdotgKB\/z3\/18Ff\/\/uPbzeGVch2QtbV2IBRMRDIAIH9\/f0Mevmmi70TzWw807OOxsg0JaQh2wlZV8\/cjeECgWwRyF40fZdns\/UUOg4EgAAQAALJEchaNDkHgZIjjg4AASAABIBAtghkLZoSdd9XTrL1FDoOBIAAEAACyRHIXjQlgj6XGyRHHB0AAkAACACBbBHohGhmiz46DgSAABAAAlkhANHMyl3oLBAAAkAACKREAKKZEn20DQSAABAAAlkh0AvRVKdst7a2CufMzc0Vtwjh581+8LNnz47g0Xe85OUYd+\/eLehhfgCg79hITPQzBBcvXjxyzzPweRNVqm4r62scMrlhzq9cuNML0ZRBUP5IoXRds9cnIVXBz3yI6DNecuyHh4cDITA\/ANBnbJRgPnz4cPCBBB0P+fe+46Pih3rw2tzcHFzx2Xds9vb2xP3798W1a9esH9PIBZ\/Oi6Z01OLiorh9+\/bgAnf5msqDBw9Kv4TSdeGUmMzMzIiTJ0+KU6dOiZGRkUGm2We8bNmBflWj5EWfuWR74NRf+frqq696jY+KGyq+PH\/+fHAvdp\/nlY7L48ePrat8OeHTedE03+OUDrQ5qOtCqY9Pjv\/rr78ulh7NTAF4HWWCzhUpCvpn6MClo5kluPNmWfb69evi6tWrYmFhYSCawObNsv7nn38uvvzyy2NbHznh0wvRNLNK1+fD+iSgNtEEXv9mgI6PbYWir1xSS\/v6ni\/weSMM8ufChQtHvsAEbN48YJlbH2qp\/+nTp8dW\/9o6tyCalm9uQjSPLl23lbxN+0lOchnsNjY2xPDwcPH\/eKCozsT7jI++ZyeXsvV7scGd47NVX+7\/xje+kc3c6oVoYkmtXF6wPGvHxhRMWSqnJaSmHyhU\/Wbg6+tckzjcuHFDXLlypTg7Ye6Pgzvl80x+xlGKZi7c6bxo5rTBHCvQ6e2Yotl3vJQISIzW19ePnPLrOzauj75\/+9vf7u1BIHW4Ti4\/mj9ra2uiz9hIPKq4c\/nyZXHixIlsuNN50cQx+GopNkWz73iZ+y4merkci2\/qAcx8BUf+u+wVlD6\/3mUTib5zpyuvc\/VCNHN5abapQFdVr000+4pXVbag3rfrKzbm6gQuf6ierbjcoHw5Nnfu9EI0U4gR2gQCQAAIAIHuIQDR7J5PMSIgAASAABBoCAGIZkPAologAASAABDoHgIQze75FCMCAkAACACBhhCAaDYELKoFAkAACACB7iEA0eyeTzEiIAAEgAAQaAgBiGZDwKJaIAAEgAAQ6B4CEM3u+RQjAgJAAAgAgYYQgGg2BCyq7ScC6uPDZaO\/ePGi+NGPfiQ++OCDI994bRot\/eIG86PjtrbVOOS3Vu\/duzf4Fm3T\/UT9QKDtCEA02+4h9C9bBNr03VZOXzg22ToLHQcCRAQgmkSgUAwI+CLQJtHh9IVj44sRygOB3BCAaObmMfQ3GwTKRMf8vVwKffnyZfHf1tZWMT71ZYyZmZniw722ZVJ9Kdi1jFr2hZbp6ekBnuayLUQzG6qhoxERgGhGBBtN9QsBH9GUl1irS+HltxelmMn9T\/V5Mv0LERLF5eXlQkiXlpYKUKXNwsJC6f6j2Rfz37YLxiGa\/eIrRktDAKJJwwmlgIA3Aj6iKbNJJZA2AdM\/yXVwcCBu3rwp7ty5I4aHhwf9sn2xRv3R7ItLZKUdRNPb5TDoAQIQzR44GUNMg4CPaMoeqqzRJZq7u7tFJmr7KTsZa\/aF8okziGYa3qDVdiMA0Wy3f9C7jBFoSjR\/+9vfHvnwMwWiKgFUy8GyHl10IZoUZFGmbwhANPvmcYw3GgJNiabMNKv2L20DpAigFE+5xLuxsVEs+1JsooGJhoBASxCAaLbEEehG9xBoSjQlUvIgkPwx90EvXbokpqamjoFJ2dM090Qhmt3jJEZUHwGIZn0MUQMQsCLQlGgODQ0Jc09SdkC+pmITTPk3W1\/k4aKVlZVB3\/XTumU2cDUQ6DsCEM2+MwDj7wUCnKyRY9MLMDHIXiMA0ey1+zH4viDAEUCOTV\/wxDj7iwBEs7++x8h7hIAUQHW7EC5s75HjMdTgCPw\/IufvdESSaekAAAAASUVORK5CYII=","height":251,"width":417}}
%---
%[output:21bbdbbb]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAc0AAAEVCAYAAACCKL5fAAAAAXNSR0IArs4c6QAAIABJREFUeF7tnU9oHte5\/0+W2ipkY\/xL1YK8KcWm\/i2EoYSLb5by7iJLmyJc402SxXUqSw5tMGkiR02yKOlCuKroRrb5QaEVdOOffRsCwpuWahuDqhpXmxIvGqiXuTyTe957dDR\/zjzvvGfmzHxeKI31nufMme\/zne\/3fc6cOfPS119\/\/bXhAwIgAAIgAAIgUInAS5hmJUY0AAEQAAEQAIEMAUwTIoAACIAACIBAIAKYZiBQNAMBEAABEAABTBMOZAg8efLELC8vm6OjoxEi6+vrZmFhIReh+\/fvm7W1NXP27FmztbVlpqenj7Vz+9vZ2TFzc3Oj723stWvXzI0bNwoz8OGHH5rNzc3s+6LjhKbP9uWPReLd45w6dcpsb2+b2dnZE12X9RE6DtvOYpAXl3euee3n5+fN7du3zdTUVO7h3fPyG+TFvnjxwqyurprd3d2seZ38VPXfFHZl5yRjyMtvndxYDP70pz+NeNDU2OuMg7bdRQDT7G5uoo2sTMDzxPX58+fmypUrZn9\/PxtjnlC5pun3EWKaGpMoAuzx48dmaWkpd6x5IpxnnGV9aBJVhrn052OWN85xTNM3RT+n9pzKfjhVGZhruk0ZT9UxMU0NG4mpgwCmWQetHrYtqghdUfeFyBqIGNEf\/\/hHc\/78+RMVj1+5uuJbZZpWwP\/xj39kv\/ZPnz49qoDqiqJvTm582XHyxmvTX3cMebSx4\/JNyR+TVLx51U8IFYuMyubmlVdeGc0S+DmxOS4z5jr9h4w3pE1T5lt0LC3WIWOnTT8QwDT7kUf1WRSJt3QoAjUzM3Niilb+LlN4Ymi\/\/e1vR\/\/tTmm6wizmVybQ\/uBtrGvG7jgvXbo0MlFrOjZG+rLTqzZGKkc5vlTGruHlGYOPR1UfWuCrTFP6tdPeeVPnvpnlYVZlai6+bk7zpqbzzrNu\/zLVnoe\/rXpfe+21bEagbFo41DRdfA8PD0fT\/D5u\/pT0T37yE\/OXv\/zFVE3P+hWvP6Vuv\/\/Vr35lfve73wVPeWv5RFw8BDDNeFh38kihImQHbyuhV199NasuxYjyhM4V8XPnzpn33ntvJIZVlaY1M1c8\/b+5JvnLX\/7S\/PrXv86Eya8QRTDfeuutoEo1r8qQsdbpIzTJVdOzRebi9u\/iU2aaeWNyp6DteT99+tRcvHjRfPLJJ1nIOPc0\/Slun2fudLcd3w9+8APz+eefB5lm3jm5xlWGr+WIb5hun+74\/bEX9Z03HZ03ziZmKkJ5RrvmEcA0m8c0mR5d0Qi9kP0KyRVcd0GQK+LvvvuuuXXr1ujX+5\/\/\/OdsEVGRKIeYpoDsi1fRVGLoeVpxzBtXaB+hya8yTVe0\/R8ZeVV1WSVYNCZrMrKQyF0AVGTMfj9V9xddE\/ONx8faxTek0gw1zbwx2P7zcLTcKzNN\/9h5Mxb2\/CwnJcZiXHafOJQ\/tGsPAUyzPexbP3JdIyj7ZS4n4xqvX\/nYilRExK88i0SorNKUGHc8ZatrQ87TFzl\/RWpIHzImv4IqMvKi6Vn3OEXiGjqWolkEd9GP5Eyw8wU9xJhD+5eV025bezx3CtTFLsQ0q37k5c1m+D\/G8n6c1Vk9W5Zre75598Yxzdalb6wBYJpjwZd+cNlUqX9PM+\/emouAaxAh04VF4lh1T9M+BhOyitc317JHTsoWvYQa1bim6VbQgk\/e1HLoWMqm3n1R9+9phiyIqdu\/vacZ0zRdg2rKNP0fPGWVpsu3svUD6SvJcM4A0xxOrnPPtGj1bN4jFlXVkVs55Bmfb3JFphm6erZqMYY94TKTsedU9RxoqFGF0qkKS\/f+rG1rTf3Zs2fZM7Xu4qqy6Vn\/h4JfaUol6I8nb4Vt0fRsSP9NT8+GVpplpqmZnj1z5kz2uJVd2S2Lpvz8yCxF3g8KTDP06uh2O0yz2\/mJMrqy+2tWqMU0fLFwB1d0381\/HMU9Vsg0XFEla03dmt2dO3eyFZJ17keWVc7+FNqkTLMowe49tZBnKEMqe\/9Y7g+FomPUzZF7jLJ7mpNYCCTHtuPNMyi\/0tQsBHKnsn083ZkKTDOKdLVyEEyzFdi7d9CqHYGqntvzK5Mvv\/wyq4Z80wxd8CEIuZVkkcDbiqPM1Iq+C1lhGVKtarJZduy8zRXKnnuV49c1zbzKOnQmwJ5v2UKgokcwmnrkpAjzOqbpT93Lv0MeOXFzIbmyq7erHlOh0tRcKd2LwTS7lxNGBAK9RyBv4VXZ6uXeA8IJJoMApplMqhgoCPQHgbzpWXt2Vfcr+4MCZ5IiAphmilljzCDQAwTypqgxzB4ktuengGn2PMGcHgiAAAiAQHMIRDVNuyBjcXHx2Kui\/AUI\/vNy7lRO3iIJ9xdr1aMDzUFHTyAAAiAAAkNDIJppFq1gtH8XM7TvVpQFAfKRf8tKtZWVFbOxsZG941AMVL63W7b5\/xYD3dvbK33P4NCSzPkac\/AfL41g+M7\/+3psSJrub+wB0QEIgEAUBKKYpvvwr2wKLWZoX0rsm55\/1q6ByndutWqfmbpw4cLoTRxStV6\/ft3cvHkz90XC3\/nOd6IAy0G6g8D\/P\/\/XY4P59z99e+zBuX020d\/YA6IDEEgUgYcPH5pvf3v8azLW6UcxzUePHmX7jcpHHpB3TdM3RffErUG6pijf25irV6+e6K8oxvYrpnlwcBAL36SOk4eNW1FVnUzdCs7vu2581Xjs900dx8WHSvM4+lxX5WwEn2J8UsMmimlauOy9S9805Z2N7jvv7APKRfdA7euaxDTzqkp\/z1Q3XW6lKb9w+PwvAvJaKBeTr1eaqcpf2sj\/keL3X9SuLEchfYS0sccoa2vxqdPfUPjlc2co5x16nuBzHCnBw\/2kVMh0wjTdl9O69zjtZtX+wqFxTTOlBIVelMcI6Ny\/O\/aDwbuXV6eK1IzDj7GVZNFxNZVmWV+a45TF2F\/ETVWuTWDalT5SqxZi4wY+VJoqzpVVmvbNFdKxvc\/56aefZguAmJ4Nh3uSRphnak0fr45xao9ddgxNn3XGHJ7JtFr+9a9\/Teq+VGx0wQfTVHEuzzRt1WhXzrqmKStkZSNu+djvm1gI1OdKUyP6IcmsawzacdQ5ziSOoemzzphDsE6xzVBNgYWF1Wyt0tvUqvDWp2d9I\/UfQWn6kZPUElRNyeMtNKIvPYjwT0L4qsYjx9UuqvHjqo5lkQo1uab7q5vLlNpPgjspnH\/f9WTcHITgE9Jm3HE0Gd+6acrJVL1docnNDVJLUJPJruqrLeHTmmbV+bjfN3EMF58m+qsz\/q63bYs7beOCnpRnIASfkDZt59k9flTT7MKJp5agmJi1JXwxDKiJY2CaxWxsizsxr4+8YzWpJ1WPy7nPtPu3rdrGoej4IfiEtOnS+WGaXcpGy2NpS\/iaMLQq6JpY8YppYpo+Ak0KPqZZdRV343tMsxt56MQoMM3yNGCamCamWU+qQn5UhLSpd9TJtsY0J4tvUr332TQlEeNWtJgmphnbNO2LueW4sumLTNHmPVXgt3OfRmhThEIMMaRNm+fgHxvT7FI2Wh5LaqZZ1wTrtvfTUWSa0i50RW7LKZ7Y4dvizsROKLDjJgXfn55172FOTU2Z1dVVI3t3+6bpvqRChi3t\/GfbA0+n8WYh+IS0aXxgY3SIaY4BXt9C2xI+rZnVjavbHtMMZ3hb3Akf4WRahgj+9H\/+1+jgzz\/5t8KB+Kbp78udtxAob9c0aXf37t1OvOkpBJ+QNpPJnq5XTFOHWy+j2hI+rZnVjavbvsw05btx++sTidriTtsYhgi+xjQvXbp0omKUZ9Y\/+OAD8\/HHH482fbEvrdjf3z8GRVfeKxyCT0ibtvPsHh\/T7FI2Wh5LW8IXy3zGPY6Pz7j9tZzuRg\/fFncaPQlFZyGCrzFN2VZUW2kqTmNiISH4hLSZ2AAVHWOaCtD6GtKW8MUyn3GPg2kWM78t7rR9LTYp+Hn3NN9++22zvb2dvRtYTDRvIZB7T1PufUq7o6MjpmcnRA5Mc0LApthtW8LXxDOUIXiHmGZZG0wT0\/QRmKRpyrHEENfW1rLDLi0tmb\/\/\/e\/HpmftKll39WxXpmZlzCH4hLQJub5jtcE0YyGdwHGGZJrZBe29Kk3+hmnqiNoWd3SjbS4qNcFv7szDegrBJ6RN2NHitMI04+CcxFHaFL6QKnBcEEMqWq1pFpnwuGNOJb5N7rSJUWqCHxurEHxC2sQed9nxMM0uZaPlsbQpfBrTjBVj01I2PYtpDvN9mqkJfmyJCcEnpE3scWOaDgKpJSgmWYZmmnWNrso06\/YXM7eTPlab3Jn0uZX1j56Uox+CT0ibNnPsH5tKs0vZaHksbQpfyNSpD8+4lWZdk8vDRzPultM8kcO3yZ2JnFBgp6kJfuBpNdYsBJ+QNo0NqIGOMM0GQOxLF20Kn28+dTEN3cauznH8PkNM0x936Ljqnm\/X2rfJnTaxaFLw\/fcKu+e1s7Nj5ubmTrx72LaZn58fPWJiV9yur68bed7TfuwjLbu7u8b25x7Df3TFflf09xDcQ\/AJaRNyrFhtMM1YSCdwnDaFr46Z5UFZx5xCjxVimjKWsv7qjCsBihQOsU3utIlbk4JvTVMeIxGDdE3r3r172Z6z8rly5Ypx21gzPHXqVPZ3MTlp\/93vfte88847Rp7dlI\/sKLS8vJw9w4lp6lmDaeqx611k28IXamZdM80y48Q0e3eZHDuhGKbpmumZM2dOmKYMyN2X9sGDB2Zvb8\/885\/\/NDdv3sw2RrBtZE9a2fTdN2b5nkozjKuYZhhOg2jVtmlWVW02CdaINPc0qxJZ55GTqr6G9H0XuNMG3l01zcPDwwyOmZmZ0RStbIDwve99L9u3Vmuav\/jFL8xXX32V\/U+meas2UgjBJ6RNG7ktOiam2aVstDyWoQpfKOzgU4zUULEJEfzQH3dNTs+Kab722mvms88+ywxS+r5165aRt6LI1nzjmObm5uZoerdqy74QfELahF6jMdphmjFQTuQYQxW+0PSAD6bpIxAi+HVN039jidyrtPvPFi0W8hcCiWnKG1DEKN99913zxRdfZK8LW1lZMW+88cZYpunuayv3SaXPjY2N0TSwi1EIPiFtQq\/RGO0wzRgoJ3IMTKE8UeCDacYwTVsF+gt85NhF1ag7Lrk3KabpvmtTKk6Zqn399ddz74lKvHtfdHp6etSle69TpmflY\/e8lfFcv3792L1TTDMRwQ8dZmq\/akLPq4l2mAKmqeXRULnTpJ7kGaL92+XLl7N7k3VM066kdRcFvfzyy7VN031FmT8dS6WpvWISimuS5AmddtBQhyp8QeAYY8CHSlNTaYbyq8gQpQK0rwgrMz17HFtpimnax0zOnz+fPccp1av\/yIqNs8eXx11sJWnjP\/roo+wxGDFNWQDkvq6s7DVkIXob0iYUwxjtmJ6NgXIix8AUqDS1VB0qd5oU\/CLTtNO08qjIz3\/+c\/PjH\/84955knmn67+isqlTz7pm6z3TaSlPGIvdeWT2rvWISimuS5AmddtBQhyp8QeBQaZbCNFTuDE1P3KnakOsmBJ+QNiHHitWGSjMW0gkcZ6jCF5oa8GF6dpLTs6E8bLMdpmkMptkmAzt2bEyB6VktJYfKndSqJG1+bRymiWmOy6FexQ9V+EKTCD5UmkOvNEOvFdsu5EdFSJu6x51keyrNSaKbWN+YApWmlrJD5Y4IPp9yBA4ODkobYJodZ1BqCYoJ51CFLxRj8KHSDOWK3w7uFCOXmiZTaWqvgh7GcWFTaWppDXfgjpY7mKYWuUhxqSUoEizZYRA+hE\/LN7gDd7TcSU2TqTS1me5hHMKH8GlpDXfgjpY7mKYWuUhxqSUoEixUmgFAYwzc0wygSW4TuMM9TS13Wo\/DNBE+LQkRPrgDd7QIYJrNIxepR0wT4dNSDdOEO3BHiwCm2TxykXrENBE+LdUwTbgDd7QIYJrNIxepR0wT4dNSDdOEO3BHiwCm2TxykXrENBE+LdUwTbgDd7QIYJrNIxepR0wT4dNSDdOEO3BHiwCm2TxykXrENBE+LdUwTbgDd7QIYJrNIxepR0wT4dNSDdOEO3BHiwCmqULuxYsXZnV11SwuLpq5ubncPu7fv2\/29vbM7du3zdTUVNbm8ePHZmlpKfvvU6dOme3tbTM7OzuKl5i1tbXs32fPnjVbW1tmeno6t39ME+FTkZdtBkth4wdFOavAZ2Cm6ZrSzs6O+dvf\/nbC2KqEyBrm7u6ukT7yTPPJkydmeXnZnD9\/fmSa8reVlRWzsbGRGaUYqLwI1Rqj\/+8803XHhmlimlVcLfoe4YM7cEeLwIBMUwzq6OgoM6433njD3LhxI6vmpGKUqk\/+XfWxpjs\/P2+ePn2axfimKab6\/vvvZ1199dVXI9P03xTuVqt2HBcuXDALCwtZ7PPnz83169fNzZs3j1WjdoyYJsJXxVdMsz5C\/KCg0qzPmm8iUtPk0g3bxYCuXLmSmdyZM2dG\/y2G51d4ZYA9evTInDt3Lmti+\/NNU4zVfuz0rPxbzNk1RfmbNdKrV6+e6M+aqh+DaVZTGuFD+KpZkt8C7sAdLXcwzRLkXBN2TVP+fuvWLfPuu++aBw8ejKZ+rWn690DFYA8PD42YZl5VKaY6MzMzqj7dIaWWIC0RNXEIH8Kn4Y3EwB24o+VOappc+Wowe4\/QnZ61Vefly5dzjakIvCLTFJN77bXXsilb957kpEzTju\/hw4faPPcy7tmzZ+b06dO9PLcmTgp8ilEEm3KGgc9xfC5evHjsDwcHB01colH6qDRNGYW7etWOan19vZZhSlyeaUrfn3322ejeaJ5pMj0bhQtUCxUwU00VAwQ2VJpalepdpakFIi8uzzSlytzc3DzR3D46cufOnew7u+CIhUBNZuR4XwgfwqdlF9yBO1ruYJolyBVNz7oh\/iMjPHKipWL9OIQP4avPmm8i4A7c0XIH02zYNP3pYTY30FKzOg7hQ\/iqWZLfAu7AHS13emWatjLc39\/PxaNq9x0tiJOMSy1Bk8TC7xvhQ\/i0fIM7cEfLndQ0OWghkA9G1QYCWvBixKWWoBiY2GMgfAiflm9wB+5ouZOaJqtM006Z3r1799gesVrQYsallqCY2CB8CJ+Wb3AH7mi5k5omj2Wa7h6wWsBix6WWoJj4IHwIn5ZvcAfuaLmTmiarTdPuSeu+jUQLWsy41BIUExuED+HT8g3uwB0td1LT5KC9Z\/MWAuWtYtWCFjMutQTFxAbhQ\/i0fIM7cEfLndQ0WV1pagFqOy61BMXEC+FD+LR8gztwR8ud1DQZ09RmuodxCB\/Cp6U13IE7Wu4kb5pVz2a6wPCcppYm3YxD+BA+LTPhDtzRcid509SeeCpxqSUoJq4IH8Kn5RvcgTta7qSmyUzPajPdwziED+HT0hruwB0tdzBNLXKR4lJLUCRYssMgfAiflm9wB+5ouZOaJldWmvKWkeXlZXN0dHQCE+5pamnSzTiED+HTMhPuwB0td3plmvbdlfIS6EuXLpnV1VWzuLhozpw5Y65cuZK943Jubk6LVStxqSUoJkgIH8Kn5RvcgTta7qSmyUGbG1hzlF2AZmZmzMLCgnn8+LFh71ktTboZh\/AhfFpmwh24o+VOr01TXhB9eHiYVZhimuw9q6VJN+MQPoRPy0y4A3e03OmVaQoIYozy8Y3ywYMHZm9vj7ecaJnSwTiED+HT0hLuwB0td3pnmu59TZmWFRPd3Nw07D2rpUh34xA+hE\/LTrgDd7Tc6Z1paoHoalxqCYqJI8KH8Gn5BnfgjpY7qWly5SMnWiC6GpdagmLiiPAhfFq+wR24o+VOapoctHr28uXL2YrZPnxSS1BMzBE+hE\/LN7gDd7TcSU2TKytNWTG7trY2wmNnZye5ZzPdZKaWIC0RNXEIH8Kn4Y3EwB24o+VOappcaZouEHYRkPyNhUBainQ3DuFD+LTshDtwR8udXpumb6DyrObW1paZnp7W4hU9LrUExQQI4UP4tHyDO3BHy53UNFldaaa476wkNbUEaYmoiUP4ED4Nb5ierUaNa6sYo9Q0udI0+zAlyz3N6osa4avGCOErxghs+MFVfQXlt+iVaT5\/\/jzZjdmLEphagrRE1MQhfAifhjf84KpGjWtrQJVmNR3SaoFpUi1oGYvwwR24o0UA02weuUg9YpoIn5ZqmCbcgTtaBDDN5pGL1COmifBpqYZpwh24o0UA02weuUg9YpoIn5ZqmCbcgTtaBAZimmULgXifZvPkabtHTKE8A+CDaWqvUbiDafISau3V0+E4LmxMU0tPuAN3tNxJbfYv9zlNf7\/ZIjCuXbuWvZw6pU9qCYqJLcKH8Gn5BnfgjpY7qWly0FtOxBjn5ua0mHQqLrUExQQP4UP4tHyDO3BHy53UNLlyRyAtEF2NSy1BMXFE+BA+Ld\/gDtzRcic1TcY0tZnuYRzCh\/BpaQ134I6WO8mbprti9syZM9k2evv7+7l4pLhpe2oJ0hJRE4fwIXwa3kgM3IE7Wu6kpslUmtpM9zAO4UP4tLSGO3BHyx1MU4tcpLjUEhQJluwwCB\/Cp+Ub3IE7Wu6kpslBlaZsZLC0tHQMk52dnSRX1KaWIC0RNXEIH8Kn4Q0\/uKpR49oqxig1Ta40TXlm8969e2Zra8tMT09nZ27ve16+fNksLCxUM6ZDLVJLUEzouLAxTS3f4A7c0XInNU1WP6fJNnpainQ3DuFD+LTshDtwR8sdTLMEuRcvXpjV1VWzuLh4bGr3yZMnZnl52RwdHWXR6+vrxypYd3r41KlTZnt728zOzo6O5O5gVLWiN7UEaYmoiUP4ED4Nb5ierUaNa2tA07N5FWXZRu5F0FjD3N3dNe79UGuYH330UWakft\/y\/crKitnY2MiM0h+P\/28x0L29PXP79m0zNTV1YjiYZjF5ubAxzWr5z28Bd+COljupafKJ6VlrWkXPZrrAVFV1tq2tBOfn583Tp0+z\/Wrttnx5Jid\/Ozw8zNp9+OGHWTd2j1u3WpXjS+V64cKFUWUq479+\/bq5efPmsWrUjiW1BGmJqIlD+BA+DW+oNKtR49oaUKVZTYfqFo8ePTLnzp3LGspmCVV72VqjfOutt06YovRhv7969eqJ\/qypukbqjhDTpNKsZizVVF2MMAV+cNXlTKqFTOXqWS0QeXEh07rudOzp06dz74HaSlRMM6+qFFOdmZnJXdmLaWKaWk5jDHAH7mgRGGilWXW\/sArOKtO09zfffPPNzPCKFg6Na5p2nA8fPqwa8qC+f\/bsmZEfKnzyEQCfYmaATflVAz7H8bl48eKxPxwcHCQjO7UqzUmapm+YgmDRVCvTs5PhF5UUU2xaZsEduKPlTmqzf50wTftISd4uQywE0lKxfhzCh\/DVZ803EXAH7mi5g2mWIJc3Pes\/cuKH88iJlor14xA+hK8+azDNEMy4topR6rVphpCjrE2eaUolubm5eSJMHk+xz1qyucG4yIfFc2FjmmFMOdkK7sAdLXcwTS1ykeJSS1AkWJhiCwAaYygGCWwwzYBLKLdJapqce0\/TLsCRM5RqTz6yiYDs5mM\/\/lZ3WsBix6WWoJj4IHwIn5ZvcAfuaLmTmibnmqZMmco+sK5hyp6vdlceO80qu\/rYv2kBix2XWoJi4oPwIXxavsEduKPlTmqaXLiNnt21x1+IY4HhLSdainQ3DuFD+LTshDtwR8ud5E3TfzayaC9XTFNLke7GIXwIn5adcAfuaLmTvGnKidvVqva+pb+pAS+h1tKj23EIH8KnZSjcgTta7vTCNOXk3Vd5+WCEvt1EC+Ik41JL0CSx8PtG+BA+Ld\/gDtzRcic1Ta61I5AWlC7FpZagmNghfAiflm9wB+5ouZOaJmOa2kz3MA7hQ\/i0tIY7cEfLHUxTi1ykuNQSFAmW7DAIH8Kn5RvcgTta7qSmyVSa2kz3MA7hQ\/i0tIY7cEfLneRN066M3d\/fr8QgxQVBqSWoMgkNNkD4ED4tneAO3NFyJzVNLqw05TGTe\/fuma2tLTM9Pa3Fo3NxqSUoJoAIH8Kn5RvcgTta7qSmyaXTs+52elNTU1pMOhWXWoJigofwIXxavsEduKPlTmqazD1NbaZ7GIfwIXxaWsMduKPlDqapRS5SXGoJigRLdhiED+HT8g3uwB0td1LTZCpNbaZ7GIfwIXxaWsMduKPlDqapRS5SXGoJigQLlWYA0BhDMUhgg2kGXEK5TVLTZCpNbaZ7GIfwIXxaWsMduKPlDqapRS5SXGoJigQLlWYA0BgDlWYATXKbwJ1i5FLTZCpN7VXQwzgubKoFLa3hDtzRcqdXpunuDrSzs2Pm5ua0uHQmLrUExQQO4UP4tHyDO3BHy53UNLmy0ix6r2aKW+hJUlNLkJaImjiED+HT8EZi4A7c0XInNU2uNM08IKyRPn36NLlt9lJLkJaImjiED+HT8AbTrEaNa2ug9zQfP35slpaWsrNfX183CwsL1WzpWAtMszghXNiYpvZyhTtwR8ud1DS5stJ0p2dTnZJ1k5lagrRE1MQhfAifhjdUmtWocW0NpNK0C4Fu3LjRi0VAkjZMk0qzWuLyWyB8cAfuaBEYiGna05S3nWxubpr5+Xlz+\/Ztk\/IbTzBNhE972WOacAfuaBEYmGna033y5IlZXl42R0dHJtVHUDBNhE972WOacAfuaBEYqGm6py3VpywMSu0l1Zgmwqe97DFNuAN3tAgMyDTd6tI\/7RRX0GKaCJ\/2ssc04Q7c0SIwENN0dwRK0SDz0oRpInzayx7ThDtwR4vAQEyzeXja7xHTRPi0LMQ04Q7c0SIwINMsm55N8blNTBPh0172mCbcgTtaBAZimnZjgwsXLphLly6Z1dVVs7i4aM6cOWOuXLliUnx+E9NE+LSXPaYJd+COFoGBmKa\/uYGsmJ2Zmcm2z5OVs3fv3k3uuU1ME+HTXvaYJtyBO1oEBmqa9+\/fN4eHh1mFKaYpJsojJ82TqK0eMYVy5MGpIkswAAAOnklEQVQH09Rem3BnIKYppynGKB\/fKB88eGD29vaoNLVXUQfjuLAxTS0t4Q7c0XIntdm\/4A3b5b6mTMvaLfVOnTpltre3zezsrBarVuJSS1BMkBA+hE\/LN7gDd7TcSU2TK01TC0RX41JLUEwcET6ET8s3uAN3tNxJTZPHMs1Hjx6Zc+fOmenpaS1e0eNSS1BMgBA+hE\/LN7gDd7TcSU2TC03TTsMKENeuXcvuadqPXVUr\/2YhkJYq3YtD+BA+LSvhDtzRcqcXpimrZO\/du5cZorwGTJ7PtPc0ZdXs0tJShk+KbzpJLUFaImriED6ET8MbiYE7cEfLndQ0+USl6W5oIAt\/5GOfyZSp2Pfeey\/p92qmliAtETVxCB\/Cp+ENplmNGtdWMUapafIJ0\/Q3NJBTdbfSG2fjdmvIsqvQ3Nzciene\/f397G\/+MdzqNm\/VrlTGa2trWWzV1n6pJaj6cmyuBRc2pqllE9yBO1rupKbJtUzzzTffzB470XysYe7u7h6b1vUrW9+0xbBXVlbMxsZG9niLv6mC\/28x0LLnR1NLkAZrbQzCh\/DBHS0CcEeLXGqaHGyarnHVBcdWgvPz8+bp06fH9qzN21nI3XnI3VxBjutWq1JVuvdb5Xsx3evXr5ubN2\/mPkOaWoLqYj1Oe0wT4dPyB+7AHS13UtPkKKZpH00RUP2N3vMqQ2ukn376aVZh2kVINinWSK9evXqiv7x7sm4yU0uQloiaOIQP4dPwRmLgDtzRcic1TY5imhbMvPulblVp28mU7AcffGB+9rOfZabp3wO1MWKaeVWlu7G8n0hJkP08fPhQm+dexj179sycPn26l+fWxEmBTzGKYFPOMPA5js\/FixeP\/eHg4KCJSzRKH4WmaRfllI2iatGNH9sV00wpQVFY8D8HoVqgWtDyDe7AHS13kq80tSceEldkmv7CHaZnQ9Bsvg3Ch\/BpWQV34I6WO5hmCXJ5pslCIC3Vmo9D+BA+LavgDtzRcgfTrGmaPHKipVrzcQgfwqdlFdyBO1ruYJo1TVOa2wqUzQ20tGsmDuFD+LRMgjtwR8sdTFOLXKS41BIUCZbsMAgfwqflG9yBO1rupKbJY70aTAtSm3GpJSgmVggfwqflG9yBO1rupKbJmKY20z2MQ\/gQPi2t4Q7c0XIH09QiFykutQRFgoXp2QCgMYZikMAG0wy4hHKbpKbJVJraTPcwDuFD+LS0hjtwR8sdTFOLXKS41BIUCRYqzQCgMQYqzQCa5DaBO8XIpabJVJraq6CHcVzYVAtaWsMduKPlDqapRS5C3MF\/vBThKN05xP\/9P4+6MxhGAgIgMBYCzz\/5t7HiuxqMaXY1M8YYTLPDyWFoIAACpQhgmt0gyKCmZzHNbpCOUYAACNRHANOsj9kkIgZlmgJgalMBk0h6UZ\/cl+K+lJZvcAfuaLmTmiZjmtpM9zAO4UP4tLSGO3BHyx1MU4tcpLjUEhQJluwwCB\/Cp+Ub3IE7Wu6kpslUmtpM9zAO4UP4tLSGO3BHyx1MU4tcpLjUEhQJFirNAKAxhmKQwAbTDLiEcpukpslUmtpM9zAO4UP4tLSGO3BHyx1MU4tcpLjUEhQJFirNAKAxBirNAJrkNoE7xcilpslUmtqroIdxXNhUC1pawx24o+UOpqlFLlJcagmKBAuVZgDQGAOVZgBNqDRrgpSaJlNp1kxwn5tjClQLWn7DHbij5Q6mqUUuUlxqCYoEC5VmANAYA5VmAE2oNGuClJomU2nWTHCfm2MKVAtafsMduKPlDqapRS5SXGoJigQLlWYA0BgDlWYATag0a4KUmiZTadZMcJ+bYwpUC1p+wx24o+UOpqlFLlJcagmKBAuVZgDQGAOVZgBNqDRrgpSaJlNp1kxwn5tjClQLWn7DHbij5Q6mqUUuUlxqCYoEC5VmANAYA5VmAE2oNGuClJomU2nWTHCfm2MKVAtafsMduKPlDqapRS5SXGoJigQLlWYA0BgDlWYATag0a4KUmiZTadZMcJ+bYwpUC1p+wx24o+UOpqlFLlJcagmKBAuVZgDQGAOVZgBNqDRrgpSaJlNp1kxwn5tjClQLWn7DHbij5Q6mqUUuUlxqCYoEC5VmANAYA5VmAE2oNGuClJomU2nWTHCfm2MKVAtafsMduKPlDqapRS5SXGoJigQLlWYA0BgDlWYATag0a4KUmiZTadZMcJ+bYwpUC1p+wx24o+UOpqlFLlJcagmKBAuVZgDQGAOVZgBNqDRrgpSaJlNp1kxwn5tjClQLWn7DHbij5Q6mqUUuUlxqCYoEC5VmANAYA5VmAE2oNGuClJomU2nWTHCfm2MKVAtafsMduKPlDqapRS5SXGoJigQLlWYA0BgDlWYATag0a4KUmiZTadZMcJ+bYwpUC1p+wx24o+UOpqlFLlJcagmKBAuVZgDQGAOVZgBNqDRrgpSaJnei0nzy5IlZXl42R0dHGdzr6+tmYWFhBP3jx4\/N0tJS9u9Tp06Z7e1tMzs7O\/r+\/v37Zm1tLfv32bNnzdbWlpmens5NXWoJqsm\/sZpjClQLWgLBHbij5U5qmty6aT5\/\/txcuXLFXL58OTNK++8bN26Yubk5I4a6srJiNjY2MqMUA\/3www9Hxuj\/Wwx0b2\/P3L5920xNTZ3IY2oJ0hJRE4fwIXwa3kgM3IE7Wu6kpsmtm6ZvigK8mOLMzExmovLf8hETlc+LFy\/M6uqqWVxczKpK+e8LFy6MKlMx3evXr5ubN28eq0ZtQlNLkJaImjiwKUcNfIrxARu4o9EciUmNO62bZlmlmWeK1lTl\/69evZpVqbYqdU3VNVI3maklSEtETRzYIHwa3qQofNrz1MZxbfXnB1frpuka3e7u7rF7lm5VKVO19iNTsIeHh5lp5lWVbqXqp0rIywcEQAAEQKA7CBwcHHRnMBUjad007SKgjz76KLuH6Vaely5dGk3FNmWayWSGgYIACIAACHQOgdZNM2\/hjl3c8+mnn2YLgPypVnufUzM927kMMCAQAAEQAIFkEOi0acqjI3fu3MnAbGohUDKZYaAgAAIgAAKdQ6B10yybnpXVs00\/ctK5DDAgEAABEACBZBBo3TQFKX9zg2vXro0qS\/m+yc0NkskMAwUBEAABEOgcAp0wzc6hwoBAAARAAARAIAcBTBNagAAIgAAIgEAgAphmIFA0AwEQAAEQAIFBmKbdJEE2T5CPf890yDSwG0XY1cmCxdDxkkeaNjc3M1r4LwAYOjaCifuChPn5+WP7PIPPN2ri76HNdXVSV\/zrKxXuDMI03f1rbWKKttkbkoFa8fN\/RAwZLzl3eduO3fDff454yNhYw7x3797ohQn+3tBDx8fqh\/3htbOzk23aIp+hYyMLPn\/zm9+Yd955J\/dlGqng03vTzNsQXlbj3r17t\/BNKH03Trta+ZVXXjGvvvpqtnWhrTSHjFdedeC+AEB44b5xR\/49JC7l\/eB03zL05ZdfDhofqxuWE0+fPh3tiz3k68rF5bPPPjv2ZIT9LiV8em+a\/qvDJEl5Ceq7UbrnJ+f\/r3\/9K5t69CsF8DrOBJcrYgrua+ng0vHqCe58My1769Yt89Zbb5m33357ZJpg8820\/h\/+8Afz+eefn7j1kRI+gzBNv6qsen3YkAw0zzTB638Z4OKTV1UOlUt2at+95ws+3xiDfF5\/\/fVjb2ACm29+YPm3PuxU\/xdffHFi9q+r1xamOTs7JI88ca6YZnH6BRsRO9nOcXp6OncqtqsXdixS+5X4kH9wuffsZCrbfW0hpnmSke50\/7e+9S1MM9ZFW3WclMr+qnOZxPdMz+aj6humvX\/J9OxxvHzhGyo+gsP7779vfvjDH5rZ2dkTq2fRoeLrbGZmxohppsKd3leaKd1gnoQpVvXpm+bQ8bImILjZFbQpLlaoyrvm+7LHKGQ1+ve\/\/\/3BLgTytwJ18V1fXx80NoJFGXcWFxfNyy+\/nAx3em+akrBUljJrhGzcGN80h46Xf9\/Fx3foXPIfwZF\/Fz2CMuTHu\/JMYujc6cvjXIMwzVQemh3XADXxeaY5VLzKqgX7vN1QsXG5xeYP1VcamxsUT8emvnHIIEyzmuK0AAEQAAEQAIFqBDDNaoxoAQIgAAIgAAIZApgmRAABEAABEACBQAQwzUCgaAYCIAACIAACmCYcAAEQAAEQAIFABDDNQKBoBgIgAAIgAAKYJhwAARAAARAAgUAEMM1AoGgGAiAAAiAAApgmHACBBhFwH\/zP63Z+ft786Ec\/Mj\/96U\/NxsZGtk9pjI+7cYP\/0vG849vzkHetbm9vRxtnDCw4BgiMgwCmOQ56xIJACQJdem+rZiyaGAgBAn1HANPse4Y5v9YQ6JLpaMaiiWkNbA4MApEQwDQjAc1hhodAken4f5ep0K+++ir73+7ubgaUfTPG8vJy9uLevGlSdyq4ahq16O01S0tLo8T407aY5vA4yxlXI4BpVmNECxBQIVDHNGUTa7spvLx7UcxM7n\/a15O5b4iQwayurmZGeuPGjWxsEvP2228X3n\/0x+L\/O2+DcUxTlXaCeo4AptnzBHN67SFQxzSlmrQGmWdg7iu5nj17Zj744APz8ccfm+np6dEJ5r2xxn7pj6XKZCUO02yPOxy5uwhgmt3NDSNLHIE6pimnaqvGKtPc39\/PKtG8T9HKWH8sIa84wzQTJyDDnwgCmOZEYKVTECiu1PLuadYxzd\/\/\/vfHXvwcgnWZAdrpYOnHNV1MMwRZ2gwNAUxzaBnnfKMhMMlKs+z+Zd4JhhigmKdM8W5tbWXTviEx0cDkQCDQEQQwzY4kgmH0D4FJmaYgJQuB5OPfB718+bJZWFg4AWbIPU3\/niim2T9OckbjI4Bpjo8hPYBALgKTMs2pqSnj35OUAchjKnmGKd\/ljUUWF62trY3G7q7WLYoh1SAwdAQwzaEzgPMfBAKaqlETMwgwOclBI4BpDjr9nPxQENAYoCZmKHhynsNFANMcbu458wEhIAZodxdiw\/YBJZ5TbRyB\/waZM0ODoeX7VQAAAABJRU5ErkJggg==","height":251,"width":417}}
%---
%[output:22578d05]
%   data: {"dataType":"text","outputData":{"text":"\n============================================================\n","truncated":false}}
%---
%[output:161f2035]
%   data: {"dataType":"text","outputData":{"text":"B5:B6 DETAILED RESULT\n","truncated":false}}
%---
%[output:93ae2baa]
%   data: {"dataType":"text","outputData":{"text":"CAN ID = 0x121\n","truncated":false}}
%---
%[output:220779d6]
%   data: {"dataType":"text","outputData":{"text":"============================================================\n","truncated":false}}
%---
%[output:699eae95]
%   data: {"dataType":"text","outputData":{"text":"\nLittle Endian:\n","truncated":false}}
%---
%[output:9360bfa9]
%   data: {"dataType":"text","outputData":{"text":"Idle median    = 46595.00\n","truncated":false}}
%---
%[output:52803d55]
%   data: {"dataType":"text","outputData":{"text":"RPM-Up median  = 46595.00\n","truncated":false}}
%---
%[output:332b05a2]
%   data: {"dataType":"text","outputData":{"text":"Ratio          = 1.000\n","truncated":false}}
%---
%[output:317471cd]
%   data: {"dataType":"text","outputData":{"text":"\nBig Endian:\n","truncated":false}}
%---
%[output:7009b81f]
%   data: {"dataType":"text","outputData":{"text":"Idle median    = 950.00\n","truncated":false}}
%---
%[output:66bfce53]
%   data: {"dataType":"text","outputData":{"text":"RPM-Up median  = 1518.00\n","truncated":false}}
%---
%[output:3aae50f6]
%   data: {"dataType":"text","outputData":{"text":"Ratio          = 1.598\n","truncated":false}}
%---
%[output:9894e9e8]
%   data: {"dataType":"text","outputData":{"text":"\n============================================================\n","truncated":false}}
%---
%[output:1cf40bea]
%   data: {"dataType":"text","outputData":{"text":"KNOWN RPM REFERENCE\n","truncated":false}}
%---
%[output:6a162676]
%   data: {"dataType":"text","outputData":{"text":"============================================================\n","truncated":false}}
%---
%[output:8df236dd]
%   data: {"dataType":"text","outputData":{"text":"Idle RPM          = 1042 RPM\n","truncated":false}}
%---
%[output:3f34da83]
%   data: {"dataType":"text","outputData":{"text":"Boom-up RPM       = 1600 - 1700 RPM\n","truncated":false}}
%---
%[output:8d745cda]
%   data: {"dataType":"text","outputData":{"text":"Expected ratio    = 1.536 - 1.631\n","truncated":false}}
%---
%[output:7c4ac6e0]
%   data: {"dataType":"text","outputData":{"text":"\n============================================================\n","truncated":false}}
%---
%[output:8f1be3f6]
%   data: {"dataType":"text","outputData":{"text":"ANALYSIS COMPLETE\n","truncated":false}}
%---
%[output:85ff5002]
%   data: {"dataType":"text","outputData":{"text":"============================================================\n","truncated":false}}
%---
