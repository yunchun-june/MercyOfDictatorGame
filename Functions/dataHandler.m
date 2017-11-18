classdef dataHandler <handle

%     columns         index
%     trials          1
%     p1choice        2
%     p1guess         3
%     p2choice        4
%     p2guess         5
%     realsum         6
%     p1IsRight       7
%     p2IsRight       8
%     winner          9
%     p1score         10
%     p2score         11
    
    
    properties
        player1ID
        player2ID
        rule
        totalTrial
        result
        gain
    end
    
    methods
        
        %-----Constructor-----%
        function obj = dataHandler(ID1,ID2,rule,trials,gain)
            obj.player1ID = ID1;
            obj.player2ID = ID2;
            obj.rule = rule;
            obj.totalTrial = trials;
            obj.result = cell(trials,11);
            obj.gain = gain;
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
            end
            
            if strcmp(obj.rule , 'player2')
                obj.result{trial,2} = oppRes.choice;
                obj.result{trial,3} = oppRes.guess;
                obj.result{trial,4} = myRes.choice;
                obj.result{trial,5} = myRes.guess;
            end
            
            %real sum
            obj.result{trial,6} = obj.result{trial,2} + obj.result{trial,4};
            
            %p1 is right
            if(obj.result{trial,6} == obj.result{trial,3})  obj.result{trial,7} = 1;
            else obj.result{trial,7} = 0; end 
            
            %p2 is right
            if(obj.result{trial,6} == obj.result{trial,5})  obj.result{trial,8} = 1;
            else obj.result{trial,8} = 0; end 
            
            
            % set winner and update score
            if( obj.result{trial,7} == 1 && obj.result{trial,8} == 0) % p1 win
                obj.result{trial,9} = 1;
                if(trial == 1)
                    obj.result{trial,10} = obj.gain;
                    obj.result{trial,11} = 0;
                else
                    obj.result{trial,10} = obj.result{trial-1,10} + obj.gain;
                    obj.result{trial,11} = obj.result{trial-1,11};
                end
                
            elseif ( obj.result{trial,7} == 0 && obj.result{trial,8} == 1) %p2 win
                obj.result{trial,9} = 2;
                if(trial == 1)
                    obj.result{trial,10} = 0;
                    obj.result{trial,11} = obj.gain;
                else
                    obj.result{trial,10} = obj.result{trial-1,10};
                    obj.result{trial,11} = obj.result{trial-1,11} + obj.gain;
                end
            else % draw
                obj.result{trial,9} = 0;
                if(trial == 1)
                    obj.result{trial,10} = 0;
                    obj.result{trial,11} = 0;
                else
                    obj.result{trial,10} = obj.result{trial-1,10};
                    obj.result{trial,11} = obj.result{trial-1,11};
                end
            end
        end
        
        function data = getResult(obj,trial)
            if strcmp(obj.rule , 'player1')
                data.yourChoice = obj.result{trial,2};
                data.yourGuess  = obj.result{trial,3};
                data.oppChoice  = obj.result{trial,4};
                data.oppGuess   = obj.result{trial,5};
                data.realSum    = obj.result{trial,6};
                data.winner     = obj.result{trial,9};
                data.yourScore  = obj.result{trial,10};
                data.oppScore   = obj.result{trial,11};
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

