classdef displayer < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        wPtr
        width
        height
        xCen
        yCen
        screenID
        row
        col
        decideTime
        displayerOn
        heart
    end
    
    properties (Constant)
        WHITE = [255 255 255];
        YELLOW = [255 255 0];
        GREEN = [0 255 0];
        RED = [255 0 0];
        GREY = [100 100 100];
        DIMYELLOW = [100 100 0];
        yGrid = [23 29 35 41 47 53 59 65 71 77];
        xGrid = [20 35 50 65 80];
    end
    
    methods
        
        %===== Constructor =====%
        function obj = displayer(screid,displayerOn)
            obj.screenID = screid;
            obj.decideTime = 10;
            obj.displayerOn = displayerOn;
    
        end
        
        %===== Open Close Screen =====%
        function openScreen(obj)
            if ~obj.displayerOn return; end
            
            [obj.wPtr, screenRect]=Screen('OpenWindow',obj.screenID, 0,[],32,2);
            [obj.width, obj.height] = Screen('WindowSize', obj.wPtr);
            obj.xCen = obj.width/2;
            obj.yCen = obj.height/2;
            for i = 1:10
                obj.row(i) = -(i-6)*obj.height/10;
            end
            
            for i = 1:5
                obj.col(i) = (i-3)*obj.width/6;
            end
            
            heart_file = dir('./heart.png');
            heart_img = imread(heart_file.name);
            obj.heart =  Screen('MakeTexture',obj.wPtr,heart_img);
        end
        
        function closeScreen(obj)
            if ~obj.displayerOn return; end
            Screen('CloseAll');
        end
        
        %===== Common Methods =====%
        
        function writeMessage(obj,line1,line2)
            if ~obj.displayerOn return; end
            obj.write(line1,2,3,'white',30);
            obj.write(line2,2,5,'white',30);
            Screen('Flip',obj.wPtr);
        end
                
        function blackScreen(obj)
            if ~obj.displayerOn return; end
            Screen('Flip',obj.wPtr);
        end
        
        function fixation(obj,fixationTime)
            if ~obj.displayerOn return; end
            l = 10;
            
            %delay
            Screen('Flip',obj.wPtr);
            WaitSecs(.5);
            
            %fixation square
            Screen('FillRect', obj.wPtr, obj.WHITE, [obj.xCen-l,obj.yCen-l,obj.xCen+l,obj.yCen+l]);
            Screen('Flip',obj.wPtr);
            WaitSecs(fixationTime);
            
            %delay
            Screen('Flip',obj.wPtr);
            WaitSecs(.5);
        end
        
        function delay(obj,time)
            if ~obj.displayerOn return; end
            Screen('Flip',obj.wPtr);
            WaitSecs(time);
        end
          
        function write(obj,text,x,y,c,size)
            if strcmp(c,'white') color = obj.WHITE; end
            if strcmp(c,'red') color = obj.RED; end
            if strcmp(c,'green') color = obj.GREEN; end
            if strcmp(c,'yellow') color = obj.YELLOW; end
            if strcmp(c,'grey') color = obj.GREY; end

            Screen('TextSize', obj.wPtr,size);
            Screen('DrawText',obj.wPtr,char(text), ceil(obj.xGrid(x)*obj.width/100), ceil(obj.yGrid(y)*obj.height/100), color);
            
        end
        
        function drawTimer(obj,t,xPosi,yPosi)
            w = 5;
            h = 20;
            margin = 13;
            x = ceil(obj.xGrid(xPosi)*obj.width/100);
            y = ceil(obj.yGrid(yPosi)*obj.height/100);
            for i = 1:t
                Screen('FillRect', obj.wPtr, obj.YELLOW, [x,y,x+w,y+h]);
                x = x+margin;
            end
        end
        
        %===== MDG =====%
        
        function MDG_decideScreen(obj,res,timer,confirmed)
            
            if ~obj.displayerOn return; end
            
            %--------------------------------------
            %1
            %2 You are @dictator/ #receiver
            %3
            %4 Your money       8 @
            %5 Opp's money      2 @
            %6 ----------
            %7 Score1 #
            %8 Score2 @
            %9 Score3 #
            %10            timer here?
            %--------------------------------------
            
%             res.youAreDictator = 1
%             res.keepMoney  =6
%             res.givenMoney = 4
%             res.state  = 'allocate' %allocate scoring
%             res.s1 = 5
%             res.s2 = 6
%             res.s3 = 7
%             res.timer = 5
    
            invalid = 0;
            if res.youAreDictator
                obj.write('DICTATOR',1,2,'white',30);
                if(~res.allocated || ~res.s2answered) invalid = 1; end
            else
                obj.write('RECEIVER',1,2,'white',30);
                if(~res.s1answered || ~res.s3answered) invalid = 1; end
            end
            
            %2 You are @dictator/ #receiver

            if(strcmp(res.state,'allocate'))
                if res.youAreDictator
                    %4 Your money       8 @
                    if(confirmed)   obj.write('Your money:',1,4,'grey',30); end
                    if(~confirmed)  obj.write('Your money:',1,4,'white',30); end
                    
                    if(res.keepMoney ~= -1) obj.write(num2str(res.keepMoney),3,4,'white',30); end

                    %5 Opp's money      2 @
                    if(confirmed) obj.write('Opp money:',1,5,'grey',30); end
                    if(~confirmed)obj.write('Opp money:',1,5,'white',30); end
                    
                    if(res.givenMoney ~= -1) obj.write(num2str(res.givenMoney),3,5,'white',30); end
                    
                else
                    obj.write('Waiting for dictator...',1,4,'white',30);
                end
            else
                if res.youAreDictator
                    %4 Your money       8 @
                    obj.write('Your money:',1,4,'grey',30);
                    
                    if(res.allocated) obj.write(num2str(res.keepMoney),3,4,'white',30); end
                    if(~res.allocated) obj.write('Not answered',3,4,'red',30); end

                    %5 Opp's money      2 @
                    obj.write('Opp money:',1,5,'grey',30);
                    if(res.allocated) obj.write(num2str(res.givenMoney),3,5,'white',30); end
                    if(~res.allocated) obj.write('Not answered',3,5,'red',30); end
                    
                else
                    %4 Your money       8 @
                    obj.write('Your money:',1,4,'grey',30);
                    obj.write(num2str(res.givenMoney),3,4,'white',30);
                    %5 Opp's money      2 @
                    obj.write('Opp money:',1,5,'grey',30);
                    obj.write(num2str(res.keepMoney),3,5,'white',30);
                end
            end
            
            %6 ----------
            divider = '----------------------------------------------------------------------------------';
            obj.write(divider,1,6,'white',30);
            
            if strcmp(res.state,'guess1')
                if res.youAreDictator
                    %8 Score2 @
                    if(confirmed)
                        obj.write('guess given to you:',1,7,'grey',30);
                    else
                        obj.write('guess given to you:',1,7,'white',30);
                    end
                    obj.MDG_drawHeart(res.s2,3,7);
                else
                    %7 Score1 #
                    if(confirmed)
                        obj.write('Give to dictator:',1,7,'grey',30);
                    else
                        obj.write('Give to dictator:',1,7,'white',30);
                    end
                    obj.MDG_drawHeart(res.s1,3,7);
                end
            end
            
            if strcmp(res.state,'guess2') || strcmp(res.state,'delay')
                if res.youAreDictator
                    %8 Score2 @
                    obj.write('guess given to you:',1,7,'grey',30);
                    if(res.s2answered) obj.MDG_drawHeart(res.s2,3,7);
                    else obj.write('Not answered',3,7,'red',30); end
                else
                    %7 Score1 #
                    obj.write('Give to dictator:',1,7,'grey',30);
                    if(res.s1answered) obj.MDG_drawHeart(res.s1,3,7);
                    else obj.write('Not answered',3,7,'red',30); end
                end
            end
                      
            if strcmp(res.state,'guess2')
                if res.youAreDictator
                    obj.write('Waiting for receiver...',1,8,'white',30);
                else
                %9 Score3 #
                    if(confirmed)
                        obj.write('Guess dictator guess:',1,8,'grey',30);
                    else
                        obj.write('Guess dictator guess:',1,8,'white',30);
                    end
                    obj.MDG_drawHeart(res.s3,3,8);
                end
            end
            
            
            if strcmp(res.state,'delay')
                if res.youAreDictator
                else
                %9 Score3 #
                    obj.write('Guess dictator guess:',1,8,'grey',30);
                    if res.s3answered obj.MDG_drawHeart(res.s3,3,8);
                    else obj.write('Not answered',3,8,'red',30); end
                end
                if invalid obj.write('Please make respond in time',3,9,'red',30); end
            end
            
            %10      timer
            obj.drawTimer(timer,2,10);
            
            Screen('Flip',obj.wPtr);
        end  

        function MDG_drawHeart(obj,n,xPosi,yPosi)
            margin = 8;
            heartSize = 40;
            x = ceil(obj.xGrid(xPosi)*obj.width/100);
            y = ceil(obj.yGrid(yPosi)*obj.height/100);
            for i = 1:n
                Screen('DrawTexture', obj.wPtr, obj.heart, [], [x;y;x+heartSize;y+heartSize]);
                x = x+margin+heartSize;
            end
        end

        %===== CDG =====%
        
        function CDG_decideScreen(obj,state,choice,guess,timer,confirmed)
            if ~obj.displayerOn return; end
            
            %--------------------------------------
            %1  timer here?
            %2  Your    Guess   Real 
            %3  Choice  Sum     Sum
            %4  1               
            %5  2       2       2
            %6  3       3       3
            %7          4       4
            %8          5       5
            %9          6       6
            %10 Your Score:   
            %--------------------------------------
            
            
            %1 Your Choice
            obj.write('Your',1,2,'white',30);
            obj.write('Choice',1,3,'white',30);
            obj.write('1',1,4,'white',30);
            obj.write('2',1,5,'white',30);
            obj.write('3',1,6,'white',30);
            if(strcmp(state,'choose'))
                obj.drawTimer(timer,1,1);
                if(~confirmed)
                    if(choice ~= 0) obj.write(num2str(choice),1,choice+3,'yellow',30); end
                end
                
                if(confirmed)
                    if(choice ~= 0) obj.write(num2str(choice),1,choice+3,'red',30); end
                end            
            end
            
            if(strcmp(state,'guessSum'))
                if(choice ~= 0) obj.write(num2str(choice),1,choice+3,'red',30); end          
            end
            
            %1 Guess Sum
            obj.write('Guess',2,2,'white',30);
            obj.write('Sum',2,3,'white',30);
            if(strcmp(state,'guessSum'))
                obj.drawTimer(timer,2,1);
                obj.write('2',2,5,'white',30);
                obj.write('3',2,6,'white',30);
                obj.write('4',2,7,'white',30);
                obj.write('5',2,8,'white',30);
                obj.write('6',2,9,'white',30);
                if(confirmed)
                    if(guess ~= 0) obj.write(num2str(guess),2,guess+3,'red',30); end
                end
                
                if(~confirmed)
                    if(guess ~= 0) obj.write(num2str(guess),2,guess+3,'yellow',30); end
                end
            end
            
            %Real Sum, Opp guess, Opp choice
            obj.write('Real',3,2,'white',30);
            obj.write('Sum',3,3,'white',30);
            
            %Opp guess sum
            obj.write('Opp',4,2,'white',30);
            obj.write('Guess',4,3,'white',30);
            
            %Opp choice
            obj.write('Opp',5,2,'white',30);
            obj.write('Choice',5,3,'white',30);
            
            Screen('Flip',obj.wPtr);
        end
        
        
        function CDG_showResult(obj,data)
            if ~obj.displayerOn return; end
            
            %--------------------------------------
            %1  timer here?
            %2  Your    Guess   Real 
            %3  Choice  Sum     Sum
            %4  1               
            %5  2       2       2
            %6  3       3       3
            %7          4       4
            %8          5       5
            %9          6       6
            %10 Your Score:   
            %--------------------------------------
            
            invalid_respond = 1;
            if(data.yourChoice && data.oppChoice)
                invalid_respond = 0;
            end
            
            %1 Your Choice
            obj.write('Your',1,2,'white',30);
            obj.write('Choice',1,3,'white',30);
            
            if(data.yourChoice ~= 0)obj.write(num2str(data.yourChoice),1,5,'white',50);end      
            if(data.yourChoice == 0)obj.write('X',1,5,'red',50);end 
            
            %1 Guess Sum
            obj.write('Guess',2,2,'white',30);
            obj.write('Sum',2,3,'white',30);
            if(data.yourGuess ~= 0)obj.write(num2str(data.yourGuess),2,5,'white',50); end
            if(data.yourGuess == 0)obj.write('X',2,5,'red',50);end
            
            %Real Sum, Opp guess, Opp choice
            obj.write('Real',3,2,'white',30);
            obj.write('Sum',3,3,'white',30);
            if(~invalid_respond) obj.write(num2str(data.realSum),3,5,'white',50); end
            if(invalid_respond) obj.write('X',3,5,'red',50); end
            
            %Opp guess sum
            obj.write('Opp',4,2,'white',30);
            obj.write('Guess',4,3,'white',30);
            if(data.oppGuess ~= 0) obj.write(num2str(data.oppGuess),4,5,'white',50); end
            if(data.oppGuess == 0) obj.write('X',4,5,'red',50); end

            %Opp choice
            obj.write('Opp',5,2,'white',30);
            obj.write('Choice',5,3,'white',30);
            if(data.oppChoice ~= 0) obj.write(num2str(data.oppChoice),5,5,'white',50); end
            if(data.oppChoice == 0) obj.write('X',5,5,'red',50); end

            %your Score
            obj.write(['You win ' num2str(data.yourScore) ' times'],1,10,'white',30);
            obj.write(['Opp win ' num2str(data.oppScore) ' times'],4,10,'white',30);

            if(strcmp(data.winner,'WIN')) obj.write('WIN',3,10,'red',30); end
            if(strcmp(data.winner,'LOSE')) obj.write('LOSE',3,10,'green',30); end
            if(strcmp(data.winner,'DRAW')) obj.write('DRAW',3,10,'white',30); end
            
%                 data.yourChoice = obj.result{trial,2};
%                 data.yourGuess  = obj.result{trial,3};
%                 data.oppChoice  = obj.result{trial,4};
%                 data.oppGuess   = obj.result{trial,5};
%                 data.realSum    = obj.result{trial,6};
%                 data.winner     = obj.result{trial,9};
%                 data.yourScore  = obj.result{trial,10};
%                 data.oppScore   = obj.result{trial,11};
            
            Screen('Flip',obj.wPtr);
        end

        
    end
    
end

