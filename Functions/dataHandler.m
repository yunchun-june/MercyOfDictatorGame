classdef dataHandler <handle

%   columns         index
%   trials          1
%   dictator        2
%   disrupted       3
%   p1get           4
%   p2get           5
%   score1          6 (given to dictator)
%   score2          7 (dictator's guess)
%   score3          8 (guess of dictator's guess)    
    
    properties
        player1ID
        player2ID
        rule
        totalTrial
        result
        
        %columns        index
        trial_num        = 1
        dictator         = 2
        disrupted        = 3
        p1get            = 4
        p2get            = 5
        p1get_dis        = 6
        p2get_dis        = 7
        score1           = 8 %(given to dictator)
        score2           = 9 %(dictator's guess)
        score3           = 10 %(guess of dictator's guess)
    end
    
    methods
        
        %-----Constructor-----%
        function obj = dataHandler(ID1,ID2,rule,trials)
            if strcmp(rule,'player1')
                obj.player1ID = ID1;
                obj.player2ID = ID2;
            else
                obj.player1ID = ID2;
                obj.player2ID = ID1;
            end
            
            obj.rule = rule;
            obj.totalTrial = trials;
            obj.result = cell(trials,10);
            
            %make condition list
            temp = zeros(trials,10);
            temp(1:trials/2, obj.dictator) = 1;
            temp(trials/2+1:trials, obj.dictator) = 2;
            
            randomIndex = randperm(trials);
            index = 1;
            for i = randomIndex
                obj.result{index,obj.dictator} = temp(i,obj.dictator);
                obj.result{index,obj.trial_num} = index;
                index = index +1;
            end
        end
        
        %----- Updating Data -----%

        
        function updateData(obj,myRes,oppRes,trial)
          
            obj.result{trial,1} = trial;
            
            % p1 p2 choice guess
            if strcmp(obj.rule , 'player1')
                obj.result{trial,2} = myRes.choice;
                obj.result{trial,3} = myRes.guess;
                obj.result{trial,4} = oppRes.choice;
                obj.result{trial,5} = oppRes.guess;
                obj.result{trial,12} = myRes.events;
                obj.result{trial,13} = oppRes.events;
            end
            
            if strcmp(obj.rule , 'player2')
                obj.result{trial,2} = oppRes.choice;
                obj.result{trial,3} = oppRes.guess;
                obj.result{trial,4} = myRes.choice;
                obj.result{trial,5} = myRes.guess;
                obj.result{trial,12} = oppRes.events;
                obj.result{trial,13} = myRes.events;
            end
            
            %real sum
            if(obj.result{trial,2} ~= 0 && obj.result{trial,4} ~= 0)
                obj.result{trial,6} = obj.result{trial,2} + obj.result{trial,4};
            else
                obj.result{trial,6} = 0;
            end
            
            WRONG   = 1;
            RIGHT   = 2;
            NONSENSE = 3;
            
            %p1 is right
            if(~obj.resMakeSense(obj.result{trial,obj.p1choice}, obj.result{trial,obj.p1guess}) || obj.result{trial,obj.p1guess} == 0)
                obj.result{trial,obj.p1IsRight} = NONSENSE;
            elseif(obj.result{trial,obj.realSum} == obj.result{trial,obj.p1guess})
                obj.result{trial,obj.p1IsRight} = RIGHT;
            else
                obj.result{trial,obj.p1IsRight} = WRONG;
            end
            
            %p2 is right
            if(~obj.resMakeSense(obj.result{trial,obj.p2choice}, obj.result{trial,obj.p2guess}) || obj.result{trial,obj.p2guess} == 0)
                obj.result{trial,obj.p2IsRight} = NONSENSE;
            elseif(obj.result{trial,obj.realSum} == obj.result{trial,obj.p2guess})
                obj.result{trial,obj.p2IsRight} = RIGHT;
            else
                obj.result{trial,obj.p2IsRight} = WRONG;
            end
            
            % set winner
                                %x  %o  %? player2
            GET_WINNER    = [   0   2   1; %x player1
                                1   0   1; %o
                                2   2   0];%?
            
            obj.result{trial,9} = GET_WINNER(obj.result{trial,7},obj.result{trial,8});
            
            % update score
            if(trial == 1)
                obj.result{trial,10} = 0;
                obj.result{trial,11} = 0;
            else
                obj.result{trial,10} = obj.result{trial-1,10};
                obj.result{trial,11} = obj.result{trial-1,11};
            end
            
            
            if( obj.result{trial,9} == 1) % p1 win
                obj.result{trial,10} = obj.result{trial,10} + obj.gain;
            end
            
            if( obj.result{trial,9} == 2) % p2 win
                obj.result{trial,11} = obj.result{trial,11} + obj.gain;
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
        
        
        %----- Writing and Loading -----%
        function saveToFile(obj)
            result = obj;
            filename = strcat('./RawData/CDG',datestr(now,'YYmmDD'),'_',datestr(now,'hhMM'),'_',obj.player1ID,'.mat');
            save(filename,'result');
            fprintf('Data saved to file.\n');
        end
        
        function data = loadData(obj,filename)
            rawData = load(filename);
            data = rawData.result;
        end
        
    end
    
end

