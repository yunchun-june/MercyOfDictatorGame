classdef MDG_dataHandler <handle

    

    properties
        player1ID
        player2ID
        rule
        totalTrial
        result
        total_point
        penalty
        payoff
        
        %columns        index
        total_col           =18
        trial_num           = 1
        dictator            = 2
        disrupted           = 3
        p1get               = 4
        p2get               = 5
        p1get_ori           = 6
        p2get_ori           = 7
        score1              = 8  %(given to dictator)
        score2              = 9  %(dictator's guess)
        score3              = 10 %(guess of dictator's guess)
        allocateRT          = 11
        s1RT                = 12
        s2RT                = 13
        s3RT                = 14
        answered_allocate   = 15
        answered_s1         = 16
        answered_s2         = 17
        answered_s3         = 18
    end
    
    methods
        
        %-----Constructor-----%
        function obj = MDG_dataHandler(ID1,ID2,rule,trials)
            if strcmp(rule,'player1')
                obj.player1ID = ID1;
                obj.player2ID = ID2;
            else
                obj.player1ID = ID2;
                obj.player2ID = ID1;
            end
            
            obj.rule = rule;
            obj.totalTrial = trials;
            obj.result = cell(trials,obj.total_col);
            
            for i = 1:trials
                obj.result{i,obj.trial_num} = i;
            end
            
        end
        
        
        function gen_condList(obj)
            trials = obj.totalTrial;
            disTrialNum = ceil(trials/8);
            temp = zeros(trials,10);
            temp(1:ceil(trials/2), obj.dictator) = 1;
            temp(ceil(trials/2)+1:trials, obj.dictator) = 2;
            
            %setup disrupted
            temp(1:trials, obj.disrupted) = 0;
            temp(1              :disTrialNum,   obj.disrupted) = 2;
            temp(disTrialNum+1  :2*disTrialNum, obj.disrupted) = -2;
            
            temp(ceil(trials/2)+1               :ceil(trials/2)+disTrialNum,    obj.disrupted) = 2;
            temp(ceil(trials/2)+disTrialNum+1 :ceil(trials/2)+disTrialNum*2,  obj.disrupted) = -2;

            randomIndex = randperm(trials);
            index = 1;
            for i = randomIndex
                obj.result{index,obj.dictator} = temp(i,obj.dictator);
                obj.result{index,obj.disrupted} = temp(i,obj.disrupted);
                index = index +1;
            end
        end
        
        %----- generate condition list -----%
        
        function condList = get_condList(obj)
            condList = zeros(obj.totalTrial,2);
            for i = 1:obj.totalTrial
                condList(i,1) = obj.result{i,obj.dictator};
                condList(i,2) = obj.result{i,obj.disrupted};
            end
        end
        
        function set_condList(obj,condList)
            for i = 1:obj.totalTrial
                obj.result{i,obj.dictator} = condList(i,1);
                obj.result{i,obj.disrupted} = condList(i,2);
            end
        end
        
        %----- Updating Data -----%
        
        function res = getDictator(obj,trial)
            res = '';
            dictator = obj.result{trial,obj.dictator};
            if(dictator == 1) res = 'player1'; end
            if(dictator == 2) res = 'player2'; end
        end
        
        function dis = getDisrupt(obj,trial)
            dis = obj.result{trial,obj.disrupted};
        end
        
        function updateData(obj,myRes,oppRes,trial)
            
%             myRes.youAreDictator = strcmp(rule,data.getDictator(trial));
%             myRes.keepMoney  = 5;
%             myRes.givenMoney = 5;
%             myRes.s1 = 4;
%             myRes.s2 = 4;
%             myRes.s3 = 4;
% 
%             %data handler respond package
%             myRes.allocateRT = 0;
%             myRes.s1RT = 0;
%             myRes.s2RT = 0;
%             myRes.s3RT = 0;

        
            if(myRes.youAreDictator)
                if(strcmp(obj.rule,'player1'))
                    obj.result{trial,obj.p1get} = myRes.keepMoney;
                    obj.result{trial,obj.p2get} = myRes.givenMoney;
                    obj.result{trial,obj.p1get_ori} = myRes.keepMoney_ori;
                    obj.result{trial,obj.p2get_ori} = myRes.givenMoney_ori;
                end
                                
                if(strcmp(obj.rule,'player2'))
                    obj.result{trial,obj.p2get} = myRes.keepMoney;
                    obj.result{trial,obj.p1get} = myRes.givenMoney;
                    obj.result{trial,obj.p2get_ori} = myRes.keepMoney_ori;
                    obj.result{trial,obj.p1get_ori} = myRes.givenMoney_ori;
                end
                
                obj.result{trial,obj.score1} = oppRes.s1;
                obj.result{trial,obj.score2} = myRes.s2;
                obj.result{trial,obj.score3} = oppRes.s3;
                
                obj.result{trial,obj.allocateRT} = myRes.allocateRT;
                obj.result{trial,obj.s1RT} = oppRes.s1RT;
                obj.result{trial,obj.s2RT} = myRes.s2RT;
                obj.result{trial,obj.s3RT} = oppRes.s3RT;
                
                obj.result{trial,obj.answered_allocate} = myRes.allocated;
                obj.result{trial,obj.answered_s1} = oppRes.s1answered;
                obj.result{trial,obj.answered_s2} = myRes.s2answered;
                obj.result{trial,obj.answered_s3} = oppRes.s3answered;
                
            end
            
            if(~myRes.youAreDictator)
                if(strcmp(obj.rule,'player1'))
                    obj.result{trial,obj.p2get} = myRes.keepMoney;
                    obj.result{trial,obj.p1get} = myRes.givenMoney;
                    obj.result{trial,obj.p2get_ori} = myRes.keepMoney_ori;
                    obj.result{trial,obj.p1get_ori} = myRes.givenMoney_ori;
                end
                
                if(strcmp(obj.rule,'player2'))
                    obj.result{trial,obj.p1get} = myRes.keepMoney;
                    obj.result{trial,obj.p2get} = myRes.givenMoney;
                    obj.result{trial,obj.p1get_ori} = myRes.keepMoney_ori;
                    obj.result{trial,obj.p2get_ori} = myRes.givenMoney_ori;
                end
                
                obj.result{trial,obj.score1} = myRes.s1;
                obj.result{trial,obj.score2} = oppRes.s2;
                obj.result{trial,obj.score3} = myRes.s3;
                
                obj.result{trial,obj.allocateRT} = oppRes.allocateRT;
                obj.result{trial,obj.s1RT} = myRes.s1RT;
                obj.result{trial,obj.s2RT} = oppRes.s2RT;
                obj.result{trial,obj.s3RT} = myRes.s3RT;
                
                obj.result{trial,obj.answered_allocate} = oppRes.allocated;
                obj.result{trial,obj.answered_s1} = myRes.s1answered;
                obj.result{trial,obj.answered_s2} = oppRes.s2answered;
                obj.result{trial,obj.answered_s3} = myRes.s3answered;
            end
        end
        
        function data = getResult(obj,trial)
            if strcmp(obj.rule , 'player1')
                data.yourChoice = obj.result{trial,2};
                data.yourGuess  = obj.result{trial,3};
                data.oppChoice  = obj.result{trial,4};
                data.oppGuess   = obj.result{trial,5};
                data.realSum    = obj.result{trial,6};
                data.yourScore  = obj.result{trial,10};
                data.oppScore   = obj.result{trial,11};
                
                if(obj.result{trial,9} == 1) data.winner = 'WIN'; end
                if(obj.result{trial,9} == 2) data.winner = 'LOSE'; end
                if(obj.result{trial,9} == 0) data.winner = 'DRAW'; end
            end
            
            if strcmp(obj.rule , 'player2')
                data.yourChoice = obj.result{trial,4};
                data.yourGuess  = obj.result{trial,5};
                data.oppChoice  = obj.result{trial,1};
                data.oppGuess   = obj.result{trial,3};
                data.realSum    = obj.result{trial,6};
                data.winner     = obj.result{trial,9};
                data.yourScore  = obj.result{trial,11};
                data.oppScore   = obj.result{trial,10};
                
                if(obj.result{trial,9} == 2) data.winner = 'WIN'; end
                if(obj.result{trial,9} == 1) data.winner = 'LOSE'; end
                if(obj.result{trial,9} == 0) data.winner = 'DRAW'; end
            end
        end
        
        function ans = getScoreByKey(obj,key)
            key = mod(key,3);
            if(key == 0) key= 3; end
            ans = 0;
            for i = key:3:obj.totalTrial
                if(strcmp(obj.rule,'player1'))
                    ans = ans+ obj.result{i,obj.p1get};
                end
                if(strcmp(obj.rule,'player2'))
                    ans = ans+ obj.result{i,obj.p2get};
                end
            end
        end
        
        function logStatus(obj,trial)
            fprintf('=================================================\n');
            fprintf('Trial          %d\n',trial);
            
            if strcmp(obj.rule , 'player1')
                fprintf('YourChoice  YourGuess\n');
                fprintf('%d          %d      \n',obj.result{trial,2},obj.result{trial,3});
                fprintf('OppChoice   oppGuess\n');
                fprintf('%d          %d      \n',obj.result{trial,4},obj.result{trial,5});
                if(obj.result{trial,9} == 0) fprintf('Result: draw\n'); end
                if(obj.result{trial,9} == 1) fprintf('Result: win\n'); end
                if(obj.result{trial,9} == 2) fprintf('Result: lose\n'); end
                fprintf('Result:')
                fprintf('Your Score: %d\n',obj.result{trial,10});
                fprintf('Opp Score: %d\n',obj.result{trial,11});
            end
            
            if strcmp(obj.rule , 'player2')
                fprintf('YourChoice  YourGuess\n');
                fprintf('%d          %d      \n',obj.result{trial,4},obj.result{trial,5});
                fprintf('OppChoice   oppGuess\n');
                fprintf('%d          %d      \n',obj.result{trial,2},obj.result{trial,3});
                if(obj.result{trial,9} == 0) fprintf('Result: draw\n'); end
                if(obj.result{trial,9} == 1) fprintf('Result: lose\n'); end
                if(obj.result{trial,9} == 2) fprintf('Result: win\n'); end
                fprintf('Your Score: %d\n',obj.result{trial,11});
                fprintf('Opp Score: %d\n',obj.result{trial,10});
            end
        end
        
        function calculate_score(obj)
            total_point    = 0;
            total_gain     = 0;
            penalty        = 0;
            
            if(strcmp(obj.rule,'player1')) playerRule = 1; end
            if(strcmp(obj.rule,'player2')) playerRule = 2; end
            
            for trial = 1:obj.totalTrial
                if(playerRule == 1)
                    total_gain = total_gain + obj.result{trial,obj.p1get};
                end
                
                if(playerRule == 2)
                    total_gain = total_gain + obj.result{trial,obj.p2get};
                end

                if(playerRule == obj.result{trial,obj.dictator}) %dictator
                    if(~obj.result{trial,obj.answered_s1}) continue; end
                    if(obj.result{trial,obj.answered_s2})
                        if(obj.result{trial,obj.score2} == obj.result{trial,obj.score1})
                            total_point = total_point+1;
                        end
                    else penalty = penalty+1; end
                end

                if(playerRule ~= obj.result{trial,obj.dictator} ) %receiver
                    if(~obj.result{trial,obj.answered_s2}) continue; end
                    if(obj.result{trial,obj.answered_s1} & obj.result{trial,obj.answered_s3})
                        if(obj.result{trial,obj.score3} == obj.result{trial,obj.score2})
                            total_point = total_point+2;
                        end
                    else penalty = penalty+1; end
                end
            end
            
            obj.total_point = total_point;
            obj.penalty     = penalty;
            obj.payoff      = total_gain/obj.totalTrial * (obj.total_point-obj.penalty);
        end
    
        function gen_random_result(obj)
            for trial = 1: obj.totalTrial
                obj.result{trial,obj.p1get} = randi(9);
                obj.result{trial,obj.p2get} = 10-obj.result{trial,obj.p1get};
                obj.result{trial,obj.score1} = randi(7);
                obj.result{trial,obj.score2} = randi(7);
                obj.result{trial,obj.score3} = randi(7);
                obj.result{trial,obj.answered_allocate} = 1;
                obj.result{trial,obj.answered_s1} = 1;
                obj.result{trial,obj.answered_s2} = 1;
                obj.result{trial,obj.answered_s3} = 1;

            end
        end
        
        %----- Writing and Loading -----%
        function saveToFile(obj)
            result = obj.result;
            filename = strcat('./RawData/MDG',datestr(now,'YYmmDD'),'_',datestr(now,'hhMM'),'_',obj.player1ID,'.mat');
            save(filename,'result');
            fprintf('Data saved to file.\n');
        end
        
        function data = loadData(obj,filename)
            rawData = load(filename);
            data = rawData.result;
        end
        
    end
    
end

