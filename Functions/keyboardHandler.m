classdef keyboardHandler < handle
    
    properties
       dev
       devInd
    end
    
    properties (Constant)
        quitkey     = 'ESCAPE';
        confirm     = 'space';
        up          = 'UpArrow';
        down        = 'DownArrow';
        %numberKey   = {'1!';'2@';'3#';'4$';'5%';'6^';'7&';'8*';'9('};
        numberKey   = {'a';'s';'d';'f';'g';'h';'j';'k';'l'};
    end
    
    methods
        
        %---- Constructor -----%
        function obj = keyboardHandler()
            
            obj.dev=PsychHID('Devices');
            obj.devInd = find(strcmpi('Keyboard', {obj.dev.usageName}) );
            KbQueueCreate(obj.devInd);  
            KbQueueStart(obj.devInd);
            KbName('UnifyKeyNames');
        end
       
        %----- Functions -----%
        
        function [keyName, timing] = getResponse(obj,timesUp)
            
            keyName = 'na';
            timing = -1;
            
            KbEventFlush(obj.devInd);
            while GetSecs()<timesUp && strcmp(keyName,'na')
               [isDown, press, release] = KbQueueCheck(obj.devInd);
                
                if press(KbName(obj.quitkey))
                    keyName = 'quitkey';
                    timing = GetSecs();
                    return;
                end

                if press(KbName(obj.confirm))
                    keyName = 'confirm';
                    timing = GetSecs();
                end
                
                for toCheck = 1:9
                    if press(KbName(obj.numberKey{toCheck}))
                        keyName = num2str(toCheck);
                        timing = GetSecs();
                    end
                end
                
            end

        end
        
        function waitSpacePress(obj)
            KbEventFlush();
            [keyIsDown, firstKeyPressTimes, firstKeyReleaseTimes] = KbQueueCheck(obj.devInd);
            while 1
                [keyIsDown, firstKeyPressTimes, firstKeyReleaseTimes] = KbQueueCheck(obj.devInd); 
                if firstKeyPressTimes(KbName('space'))
                    fprintf('space is pressed.\n');
                    break;
                end
            end
        end
        
        function flushKbEvent(obj)
            KbEventFlush();
        end
        
        function result = detectSpacePress(obj)
            [keyIsDown, firstKeyPressTimes, firstKeyReleaseTimes] = KbQueueCheck(obj.devInd);
            if firstKeyPressTimes(KbName('space'))
                fprintf('space is pressed.\n');
                result = 1;
            else
                result  =0;
            end
        end
        
        function waitEscPress(obj)
            KbEventFlush();
            [keyIsDown, firstKeyPressTimes, firstKeyReleaseTimes] = KbQueueCheck(obj.devInd);
            while 1
                [keyIsDown, firstKeyPressTimes, firstKeyReleaseTimes] = KbQueueCheck(obj.devInd); 
                if firstKeyPressTimes(KbName(obj.quitkey))
                    break;
                end
            end
        end
        
    end
    
end

