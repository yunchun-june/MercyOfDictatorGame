clear all;
close all;
clc;
addpath('./Functions');
Screen('Preference', 'SkipSyncTests', 1);

try
    %===== Parameters =====%

    totalTrials         = 3;
    practiceTrials      = 15;
    
    choiceTime          = 5;
    guessSumTime        = 5;
    showResultTime      = 3;
    fixationTime        = 1;
    pointPerWin         = 10;
    
    %===== Constants =====%
    MARKET_BASELINE     = 1;
    MARKET_BUBBLE       = 2;
    MARKET_BURST        = 3;
    TRUE                = 1;
    FALSE               = 0;
    
    %===== IP Config for developing ===%
    myID = 'test';
    oppID = 'test';
    myIP = 'localhost';
    oppIP = 'localhost';

    rule = input('Rule(player1/player2): ','s');
    assert( strcmp(rule,'player1')|strcmp(rule,'player2'));
    if rule == 'player1'
        myPort = 5656;
        oppPort = 7878;
    else
        myPort = 7878;
        oppPort = 5656;
    end
    
%     %===== IP Config for 505 ===%
%     myID = input('This seat: ','s');
%     oppID = input('Opp seat: ','s');
%     fprintf('cmd to open terminal. "IPConfig" to get IP (the one with 172.16.10.xxx)\n');
%     myIP = input('This IP: ','s');
%     myIP = strcat('172.16.10.',myIP);
%     oppIP = input('Opp IP: ','s');
%     oppIP = strcat('172.16.10.',oppIP);
%     myPort = 5454;
%     oppPort = 5454;
%     if myID(2) == 'a' | myID(2)=='A'
%         rule = 'player1';
%     else
%         rule = 'player2';
%     end
    
    %===== Inputs =====%

    fprintf('---Starting Experiment---\n');
    inputDeviceName     = 'Mac';
    displayerOn         = FALSE;
    screenID            = 0;
    
    %===== Initialize Componets =====%
    keyboard    = keyboardHandler(inputDeviceName);
    displayer   = displayer(max(Screen('Screens')),displayerOn);
    parser      = parser();
    
    %===== Establish Connection =====% 
    cnt = connector(rule,myID, oppID,myIP,myPort,oppIP,oppPort);
    cnt.establish(myID,oppID);
    %ListenChar(2);
    %HideCursor();
    
    %===== Open Screen =====% 
    %fprintf('Start after 10 seconds\n');
    %WaitSecs(10);
    displayer.openScreen();
    
    displayer.writeMessage('Do not touch any key','Wait for instructions');
    fprintf('Press Space to start.\n');
    keyboard.waitSpacePress();
    displayer.blackScreen();
    fprintf('Game Start.\n');

    %===== Start of real experiment =====%
    
    %displayer.writeMessage('This is the real experiment','Press space to start');
    %keyboard.waitSpacePress();
    %displayer.blackScreen();
    
    %reinitialized components
    data        = dataHandler(myID,oppID,rule,totalTrials,pointPerWin);
    
    for trial = 1:totalTrials

        %=========== Setting Up Trials ==============%
        
        %Syncing
        if(trial == 1)
            displayer.writeMessage('Waiting for Opponent.','');
            fprintf('Waiting for Opponent.\n');
            cnt.syncTrial(trial);
            displayer.blackScreen();
        else
            cnt.syncTrial(trial);
        end
        
        %response to get
        myRes.choice = 0;
        myRes.guess  = 0;
        myRes.events = cell(0,2);
        
        %=========== Fixation ==============%
        displayer.fixation(fixationTime);
       
        %========== Make Decision ===============%
    
        %get choice 1-3
        myRes.choice = input('Your choice (1-3): ','s');
        myRes.choice = str2num(myRes.choice);
        assert(myRes.choice >= 1 && myRes.choice <= 3);
        %get guess 2-6
        myRes.guess = input('Your choice (2-6): ','s');
        myRes.guess = str2num(myRes.guess);
        assert(myRes.guess >= 2 && myRes.guess <= 6);
        
        %========== Exchange and Save Data ===============%
        %Get opponent's response
        oppResRaw = cnt.sendOwnResAndgetOppRes(parser.resToStr(myRes));
        oppRes = parser.strToRes(oppResRaw);
        data.updateData(myRes,oppRes,trial);
        
        %========== Show result ===============%
        data.logStatus(trial);
        
    end

    displayer.closeScreen();
    ListenChar();
    data.saveToFile();
    fprintf('----END OF EXPERIMENT----\n');
    
catch exception
    fprintf(1,'Error: %s\n',getReport(exception));
    displayer.closeScreen();
    ListenChar();
    ShowCursor();
end
