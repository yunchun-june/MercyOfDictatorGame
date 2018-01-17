classdef MDG < handle
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
        function obj = MDG(keyboard, displayer, connector,rule,myID,oppID,total,isRealExp)

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

                allocateTime        = 5;
                guessTime1          = 5;
                guessTime2          = 5;
                showResultTime      = 2;
                fixationTime        = 1;

                %===== Constants =====%
                TRUE                = 1;
                FALSE               = 0;

                %===== Inputs =====%

                fprintf('---Starting Experiment---\n');

                if(strcmp(obj.rule,'player1')) displayerOn = TRUE; end
                if(strcmp(obj.rule,'player2')) displayerOn = FALSE; end
                automode = FALSE;

                %===== Initialize Componets =====%
                %keyboard    = keyboardHandler(inputDeviceName);
                %displayer   = displayer(max(Screen('Screens')),displayerOn);
                parser      = MDG_parser();
                data        = MDG_dataHandler(obj.myID,obj.oppID,obj.rule,obj.totalTrials);

                %===== Start of real experiment ======%

                %generate condition list
                
                obj.displayer.writeMessage('Waiting for Opponent.','');
                fprintf('Waiting for Opponent.\n');
                
                if(strcmp(obj.rule,'player1'))
                    data.gen_condList();
                    condList = data.get_condList;
                    obj.cnt.sendCondList(parser.listToStr(condList));
                end
 
                if(strcmp(obj.rule,'player2'))
                    condListStr = obj.cnt.getCondList();
                    data.set_condList(parser.strToList(condListStr));
                end
                
                obj.displayer.blackScreen();

                action = cell(1,3);
                action{1} = 'up';
                action{2} = 'down';
                action{3} = 'confirm';
                action{4} = 'na';

                for trial = 1:obj.totalTrials

                    invalid_res = 0;
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

                    %display respond package
                    myRes.youAreDictator = strcmp(obj.rule,data.getDictator(trial));
                    myRes.keepMoney_ori     = -1;
                    myRes.givenMoney_ori    = -1;
                    myRes.keepMoney         = -1;
                    myRes.givenMoney        = -1;
                    myRes.disrupt           = data.getDisrupt(trial);
                    myRes.s1                = -1;
                    myRes.s2                = -1;
                    myRes.s3                = -1;
                    myRes.allocated         = FALSE;
                    myRes.s1answered        = FALSE;
                    myRes.s2answered        = FALSE;
                    myRes.s3answered        = FALSE;
                    myRes.allocateRT        = 0;
                    myRes.s1RT              = 0;
                    myRes.s2RT              = 0;
                    myRes.s3RT              = 0;

                    %=========== Fixation ==============%
                    obj.displayer.fixation(fixationTime);

                    %=========== Fixation ==============%

                    if myRes.youAreDictator
                        obj.displayer.writeMessage('DICTATOR','');
                        WaitSecs(2);
                    end

                    if ~myRes.youAreDictator
                        obj.displayer.writeMessage('RECEIVER','');
                        WaitSecs(2);
                    end

                    %========== Allocate Money ===============%
                    myRes.state  = 'allocate';
                    startTime = GetSecs(); 
                    decisionMade = FALSE;
                    if myRes.youAreDictator
                        fprintf('Please Allocate money.\n');
                        for elapse = 1:allocateTime
                            remaining = allocateTime-elapse+1;
                            endOfThisSecond = startTime+elapse;
                            fprintf('remaining time: %d\n',remaining);
                            obj.displayer.MDG_decideScreen(myRes,remaining,decisionMade);
                            while(GetSecs()<endOfThisSecond)
                                if ~decisionMade
                                   if(automode)
                                       keyName = action{randi(4)};
                                       timing = 3;
                                   else [keyName,timing] = obj.keyboard.getResponse(endOfThisSecond); end

                                   if(strcmp(keyName,'na')) continue;
                                   else
                                       if(strcmp(keyName,'confirm') && myRes.keepMoney ~= -1)
                                            myRes.allocateRT = timing;
                                            myRes.allocated = TRUE;
                                            decisionMade = TRUE;
                                            fprintf('confirmed: keep %d$ give %d$\n',myRes.keepMoney);
                                            obj.displayer.MDG_decideScreen(myRes,remaining,decisionMade);
                                       end

                                       if strcmp(keyName,'quitkey')
                                            obj.displayer.closeScreen();
                                            ListenChar();
                                            fprintf('---- MANUALLY STOPPED ----\n');
                                            return;
                                       end

                                       try
                                          keyName = str2num(keyName);
                                          if keyName >= 1 && keyName <=9
                                            myRes.keepMoney  = keyName;
                                            myRes.givenMoney = 10 - myRes.keepMoney;
                                            obj.displayer.MDG_decideScreen(myRes,remaining,decisionMade);
                                            fprintf('keep: %d$ give: %d$\n',myRes.keepMoney, myRes.givenMoney);
                                          end 
                                       catch end
                                   end
                                end
                            end
                        end
                        obj.displayer.MDG_decideScreen(myRes,0,decisionMade);
                    end

                    if ~myRes.youAreDictator
                        fprintf('Waiting for dictator to allocate\n');
                        for elapse = 1:allocateTime
                            remaining = allocateTime-elapse+1;
                            endOfThisSecond = startTime+elapse;
                            fprintf('remaining time: %d\n',remaining);
                            while(GetSecs()<endOfThisSecond)
                                obj.displayer.MDG_decideScreen(myRes,remaining,decisionMade);
                            end
                        end
                        obj.displayer.MDG_decideScreen(myRes,0,decisionMade);
                    end

                    %========== Sync money ===============%

                    if(myRes.youAreDictator)
                        if(~myRes.allocated)
                            myRes.keepMoney = 1;
                            myRes.givenMoney = 9;
                        end

                        myRes.keepMoney_ori = myRes.keepMoney;
                        myRes.givenMoney_ori = myRes.givenMoney;
                        obj.cnt.sendMoney(myRes.keepMoney_ori);
                    else
                        myRes.keepMoney_ori = obj.cnt.getMoney();
                        myRes.givenMoney_ori = 10-myRes.keepMoney_ori;
                    end

                    myRes.keepMoney = myRes.keepMoney_ori + myRes.disrupt;
                    if(myRes.keepMoney >9) myRes.keepMoney = 9; end
                    if(myRes.keepMoney <1) myRes.keepMoney = 1; end
                    myRes.givenMoney = 10-myRes.keepMoney;

                    %========== Guess1 ===============%

                    myRes.state  = 'guess1';
                    startTime = GetSecs();
                    decisionMade = FALSE;
                    if myRes.youAreDictator
                        fprintf('Please Guess how many heart given to you\n');

                        for elapse = 1:guessTime1
                            remaining = guessTime1-elapse+1;
                            endOfThisSecond = startTime+elapse;
                            fprintf('remaining time: %d\n',remaining);
                            obj.displayer.MDG_decideScreen(myRes,remaining,decisionMade);

                            while(GetSecs()<endOfThisSecond)
                                if ~decisionMade

                                   % get respond
                                   if(automode)
                                       keyName = action{randi(4)};
                                       timing = 3;
                                   else
                                       [keyName,timing] = obj.keyboard.getResponse(endOfThisSecond);
                                   end

                                   if(strcmp(keyName,'na'))
                                       continue;
                                   else
                                       if(strcmp(keyName,'confirm'))
                                            myRes.s2RT= timing;
                                            decisionMade = TRUE;
                                            myRes.s2answered = TRUE;
                                            fprintf('confirmed: you guess %d heart(s)\n',myRes.s2);
                                            obj.displayer.MDG_decideScreen(myRes,remaining,decisionMade);
                                       end

                                       if strcmp(keyName,'quitkey')
                                            obj.displayer.closeScreen();
                                            ListenChar();
                                            fprintf('---- MANUALLY STOPPED ----\n');
                                            return;
                                       end

                                       try
                                          keyName = str2num(keyName);
                                          if keyName >= 1 && keyName <=7
                                            myRes.s2  = keyName;
                                            obj.displayer.MDG_decideScreen(myRes,remaining,decisionMade);
                                            fprintf('%d heart(s).\n',myRes.s2);
                                          end 
                                       catch
                                       end

                                   end
                                end
                            end
                        end
                        obj.displayer.MDG_decideScreen(myRes,0,decisionMade);
                    end

                    if ~myRes.youAreDictator
                        fprintf('Please give hearts to dictator\n');
                        for elapse = 1:guessTime1
                            remaining = guessTime1-elapse+1;
                            endOfThisSecond = startTime+elapse;
                            fprintf('remaining time: %d\n',remaining);
                            obj.displayer.MDG_decideScreen(myRes,remaining,decisionMade);

                            while(GetSecs()<endOfThisSecond)
                                if ~decisionMade
                                   % get respond
                                   if(automode)
                                       keyName = action{randi(4)};
                                       timing = 3;
                                   else
                                       [keyName,timing] = obj.keyboard.getResponse(endOfThisSecond);
                                   end

                                   if(strcmp(keyName,'na'))
                                       continue;
                                   else
                                       if(strcmp(keyName,'confirm'))
                                            myRes.s1RT= timing;
                                            decisionMade = TRUE;
                                            myRes.s1answered = TRUE;
                                            fprintf('confirmed: you give %d heart(s)\n',myRes.s1);
                                            obj.displayer.MDG_decideScreen(myRes,remaining,decisionMade);
                                       end

                                       if strcmp(keyName,'quitkey')
                                            obj.displayer.closeScreen();
                                            ListenChar();
                                            fprintf('---- MANUALLY STOPPED ----\n');
                                            return;
                                       end

                                       try
                                          keyName = str2num(keyName);
                                          if keyName >= 1 && keyName <=7
                                            myRes.s1  = keyName;
                                            obj.displayer.MDG_decideScreen(myRes,remaining,decisionMade);
                                            fprintf('%d heart(s).\n',myRes.s1);
                                          end 
                                       catch
                                       end

                                   end
                                end
                            end
                        end
                        obj.displayer.MDG_decideScreen(myRes,0,decisionMade);
                    end

                    %========== Guess2 ===============%
                    myRes.state  = 'guess2';
                    startTime = GetSecs();
                    decisionMade = FALSE;
                    if myRes.youAreDictator
                        fprintf('Waiting for receiver to guess.\n');
                        for elapse = 1:guessTime2
                            remaining = guessTime2-elapse+1;
                            endOfThisSecond = startTime+elapse;
                            fprintf('remaining time: %d\n',remaining);
                            while(GetSecs()<endOfThisSecond)
                                obj.displayer.MDG_decideScreen(myRes,remaining,decisionMade);
                            end
                        end
                        obj.displayer.MDG_decideScreen(myRes,0,decisionMade);
                    end    

                    if ~myRes.youAreDictator
                        fprintf('Please Guess dictators guess.\n');
                        for elapse = 1:guessTime2
                            remaining = guessTime2-elapse+1;
                            endOfThisSecond = startTime+elapse;
                            fprintf('remaining time: %d\n',remaining);
                            obj.displayer.MDG_decideScreen(myRes,remaining,decisionMade);

                            while(GetSecs()<endOfThisSecond)
                                if ~decisionMade

                                   % get respond
                                   if(automode)
                                       keyName = action{randi(4)};
                                       timing = 3;
                                   else
                                       [keyName,timing] = obj.keyboard.getResponse(endOfThisSecond);
                                   end

                                   if(strcmp(keyName,'na'))
                                       continue;
                                   else
                                       if(strcmp(keyName,'confirm'))
                                            myRes.s3RT= timing;
                                            decisionMade = TRUE;
                                            myRes.s3answered = TRUE;
                                            fprintf('confirmed : you guess %d heart(s).\n',myRes.s3);
                                            obj.displayer.MDG_decideScreen(myRes,remaining,decisionMade);
                                       end

                                       if strcmp(keyName,'quitkey')
                                            obj.displayer.closeScreen();
                                            ListenChar();
                                            fprintf('---- MANUALLY STOPPED ----\n');
                                            return;
                                       end

                                       try
                                          keyName = str2num(keyName);
                                          if keyName >= 1 && keyName <=7
                                            myRes.s3  = keyName;
                                            obj.displayer.MDG_decideScreen(myRes,remaining,decisionMade);
                                            fprintf('%d heart(s).\n',myRes.s3);
                                          end 
                                       catch
                                       end
                                   end
                                end
                            end
                        end
                        obj.displayer.MDG_decideScreen(myRes,0,decisionMade);
                    end

                    myRes.state  = 'delay';
                    endTime = GetSecs()+showResultTime;
                    while GetSecs() < endTime
                        obj.displayer.MDG_decideScreen(myRes,0,TRUE);
                    end

                    %========== Exchange and Save Data ===============%
                    %Get opponent's response
                    oppResRaw = obj.cnt.sendOwnResAndgetOppRes(parser.resToStr(myRes));
                    oppRes = parser.strToRes(oppResRaw);
                    data.updateData(myRes,oppRes,trial);

                    %========== Show result ===============%
                    WaitSecs(3);
                    obj.displayer.blackScreen();
                end

                if(obj.isRealExp) data.saveToFile(); end
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
