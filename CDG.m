classdef CDG < handle
    properties
        cnt
        keyboard
        displayer
        rule
        myID
        oppID
        totalTrials
        isRealExp
    end
    
    methods
        
        %---- Constructor -----%
        function obj = CDG(keyboard, displayer, connector,rule,myID,oppID,total,isRealExp)

            obj.keyboard    = keyboard;
            obj.displayer   = displayer;
            obj.cnt         = connector;
            obj.rule        = rule;
            obj.myID        = myID;
            obj.oppID       = oppID;
            obj.totalTrials = total;
            obj.isRealExp  = isRealExp;
            
        end
        
        function run(obj)

            try
                %===== Parameters =====%
                choiceTime          = 5;
                guessSumTime        = 5;
                showResultTime      = 5;
                fixationTime        = 1;
                gainPerWin          = 3;

                %===== Constants =====%
                TRUE                = 1;
                FALSE               = 0;

                %===== Inputs =====%

                fprintf('---Starting Experiment---\n');

                if(strcmp(obj.rule,'player1')) displayerOn = TRUE; end
                if(strcmp(obj.rule,'player2')) displayerOn = FALSE; end

                %===== Initialize Componets =====%
                %keyboard    = keyboardHandler(inputDeviceName);
                %displayer   = displayer(max(Screen('Screens')),displayerOn);
                parser      = CDG_parser();
                data        = CDG_dataHandler(obj.myID,obj.oppID,obj.rule,obj.totalTrials,gainPerWin);

                %===== Start of real experiment ======%

                for trial = 1:obj.totalTrials

                    %=========== Setting Up Trials ==============%

                    %Syncing
                    if(trial == 1)
                        obj.displayer.writeMessage('Waiting for Opponent.','');
                        fprintf('Waiting for Opponent.\n');
                        obj.cnt.syncTrial(trial);
                        obj.displayer.blackScreen();
                    else
                        obj.cnt.syncTrial(trial);
                    end

                    %response to get
                    myRes.choice = 0;
                    myRes.guess  = 0;
                    myRes.events = cell(0,2);

                    %=========== Fixation ==============%
                    obj.displayer.fixation(fixationTime);

                    %========== Make Choice ===============%

                    %if strcmp(rule,'player2')
                    %    myRes.choice = randi(3);
                    %    myRes.guess = myRes.choice + randi(3);
                    %end

                    startTime = GetSecs();
                    decisionMade = FALSE;
                    fprintf('Make your choice.\n');
                    for elapse = 1:choiceTime
                        remaining = choiceTime-elapse+1;
                        endOfThisSecond = startTime+elapse;
                        fprintf('remaining time: %d\n',remaining);

                        obj.displayer.CDG_decideScreen('choose',myRes.choice,myRes.guess,remaining,decisionMade);

                        while(GetSecs()<endOfThisSecond)
                            if ~decisionMade
                               [keyName,timing] = obj.keyboard.getResponse(endOfThisSecond);
                               if(strcmp(keyName,'na'))
                                   continue;
                               else

                                   if(strcmp(keyName,'confirm') && myRes.choice ~= 0)
                                        decisionMade = TRUE;
                                        fprintf('decision confirmed : %d\n',myRes.choice);
                                        obj.displayer.CDG_decideScreen('choose',myRes.choice,myRes.guess,remaining,decisionMade);
                                   end

                                   if strcmp(keyName,'quitkey')
                                        obj.displayer.closeScreen();
                                        ListenChar();
                                        fprintf('---- MANUALLY STOPPED ----\n');
                                        return;
                                   end

                                   try
                                      keyName = str2num(keyName);
                                      if keyName >= 1 && keyName <=3
                                        myRes.choice = keyName;
                                        fprintf('choose %d\n',keyName);
                                        obj.displayer.CDG_decideScreen('choose',myRes.choice,myRes.guess,remaining,decisionMade);
                                      end 
                                   catch
                                   end

                                   myRes.events{end+1,1} = keyName;
                                   myRes.events{end,2} = num2str(timing-startTime);

                               end
                            end
                        end
                    end
                    if(~decisionMade) myRes.choice = 0; end

                    %========== Guess Sum ===============%
                    startTime = GetSecs();
                    decisionMade = FALSE;
                    fprintf('Guess total Sum.\n');
                    for elapse = 1:guessSumTime
                        endOfThisSecond = startTime+elapse;
                        remaining = guessSumTime-elapse+1;
                        obj.displayer.CDG_decideScreen('guessSum',myRes.choice,myRes.guess,remaining,decisionMade);

                        fprintf('remaining time: %d\n',remaining);
                        while(GetSecs()<endOfThisSecond)
                            if ~decisionMade
                               [keyName,timing] = obj.keyboard.getResponse(endOfThisSecond);
                               if(strcmp(keyName,'na'))
                                   continue;
                               else

                                   if(strcmp(keyName,'confirm') && myRes.guess ~= 0)
                                        decisionMade = TRUE;
                                        fprintf('decision confirmed : %d\n',myRes.guess);
                                        obj.displayer.CDG_decideScreen('guessSum',myRes.choice,myRes.guess,remaining,decisionMade);
                                   end

                                   if strcmp(keyName,'quitkey')
                                        obj.displayer.closeScreen();
                                        ListenChar();
                                        fprintf('---- MANUALLY STOPPED ----\n');
                                        return;
                                   end

                                   try
                                      keyName = str2num(keyName);
                                      if keyName >= 2 && keyName <=6
                                        myRes.guess = keyName;
                                        fprintf('choose %d\n',keyName);
                                        obj.displayer.CDG_decideScreen('guessSum',myRes.choice,myRes.guess,remaining,decisionMade);
                                      end 
                                   catch
                                   end

                                   myRes.events{end+1,1} = keyName;
                                   myRes.events{end,2} = num2str(timing-startTime);
                               end 

                            end
                        end
                    end
                    obj.displayer.CDG_decideScreen('guessSum',myRes.choice,myRes.guess,0,1);
                    if(~decisionMade) myRes.guess = 0; end

                    %========== Exchange and Save Data ===============%
                    %Get opponent's response
                    oppResRaw = obj.cnt.sendOwnResAndgetOppRes(parser.resToStr(myRes));
                    oppRes = parser.strToRes(oppResRaw);
                    data.updateData(myRes,oppRes,trial);

                    %========== Show result ===============%
                    resultData = data.getResult(trial);
                    data.logStatus(trial);

                    obj.displayer.CDG_showResult(resultData);
                    WaitSecs(showResultTime);
                    obj.displayer.blackScreen();
                end

                %==== random number ====%
                obj.displayer.writeMessage('End of Experiment','');
                WaitSecs(4);
                obj.displayer.blackScreen();
                WaitSecs(1);

                if(obj.isRealExp)
                    spacePressed = FALSE;
                    obj.keyboard.flushKbEvent();
                    random = 0;
                    fprintf('Spress to get a ramdom key.\n');
                    while(~spacePressed)
                        random = randi(99);
                        obj.displayer.writeMessage('Press space to get key',num2str(random));
                        WaitSecs(0.1);
                        spacePressed = obj.keyboard.detectSpacePress();
                    end
                    obj.displayer.writeMessage('Press space to get key',num2str(random));
                    WaitSecs(1);
                    obj.displayer.blackScreen();
                    WaitSecs(1);    
                    fianlScore = data.setKeyGetScore(random);
                    obj.displayer.writeMessage(['Your Score: ',num2str(fianlScore)],['Your Total Payoff: ',num2str(fianlScore*gainPerWin), '$']);
                    WaitSecs(5);

                    data.saveToFile();
                end              
                
                fprintf('----END OF EXPERIMENT----\n');

            catch exception
                fprintf(1,'Error: %s\n',getReport(exception));
                obj.displayer.closeScreen();
                ListenChar();
                ShowCursor();
                if(obj.isRealExp) data.saveToFile(); end
            end

        end
        
        
        
    end
    
end
