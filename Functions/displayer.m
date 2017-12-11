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
        end
        
        function closeScreen(obj)
            if ~obj.displayerOn return; end
            Screen('CloseAll');
        end
        
        %===== Display =====%
        
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

        function decideScreen(obj,res,timer,confirmed)
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
            
            
            %2 You are @dictator/ #receiver
            if res.youAreDictator
                obj.write('You are dictator',1,2,'white',30);
            else
                obj.write('Your are receiver',1,2,'white',30);
            end
            
            if(strcmp(res.state,'allocate'))
                if res.youAreDictator
                    %4 Your money       8 @
                    obj.write('Your money:',1,4,'white',30);
                    obj.write(num2str(res.keepMoney),3,4,'white',30);

                    %5 Opp's money      2 @
                    obj.write('Opp money:',1,5,'white',30);
                    obj.write(num2str(res.givenMoney),3,5,'white',30);
                else
                    obj.write('Waiting for dictator...',1,4,'white',30);
                end
            else
                %4 Your money       8 @
                    obj.write('Your money:',1,4,'white',30);
                    obj.write(num2str(res.keepMoney),3,4,'white',30);

                %5 Opp's money      2 @
                    obj.write('Opp money:',1,5,'white',30);
                    obj.write(num2str(res.givenMoney),3,5,'white',30);
            end
            
            %6 ----------
            divider = '------------------------------------------------------------';
            obj.write(divider,1,6,'white',30);
            
            if strcmp(res.state,'guess1') || strcmp(res.state,'guess2')
                if res.youAreDictator
                    %8 Score2 @
                    obj.write('Score given to you:',1,7,'white',30);
                    obj.write(num2str(res.s2),3,7,'white',30);
                else
                    %7 Score1 #
                    obj.write('Score give to dictator:',1,7,'white',30);
                    obj.write(num2str(res.s1),3,7,'white',30);
                end
            end
            
            if strcmp(res.state,'guess2')
                if res.youAreDictator
                    obj.write('Waiting got for receiver...',1,8,'white',30);
                else
                %9 Score3 #
                    obj.write('Dictator guess:',1,8,'white',30);
                    obj.write(num2str(res.s3),3,8,'white',30);
                end
            end
            
            %10      timer
            obj.drawTimer(timer,3,10);
            
            Screen('Flip',obj.wPtr);
        end
        
        
        function write(obj,text,x,y,c,size)
            if strcmp(c,'white') color = obj.WHITE; end
            if strcmp(c,'red') color = obj.RED; end
            if strcmp(c,'green') color = obj.GREEN; end
            if strcmp(c,'yellow') color = obj.YELLOW; end

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

        
    end
    
end

