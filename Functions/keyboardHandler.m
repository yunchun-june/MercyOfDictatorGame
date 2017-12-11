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
    end
    
    methods
        
        %---- Constructor -----%
        function obj = keyboardHandler(keyboardName)
            if strcmp(keyboardName,'Mac')
               keyboardName = 'Apple Internal Keyboard / Trackpad';
            end
            if strcmp(keyboardName,'Wireless')
                keyboardName = 'USB Receiver';
            end
            if strcmp(keyboardName,'USB')
                keyboardName = 'USB Keyboard';
            end
            
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
                
                if press(KbName(obj.up))
                    keyName = 'up';
                    timing = GetSecs();
                end
                
                if press(KbName(obj.down))
                    keyName = 'down';
                    timing = GetSecs();
                end
                
            end

        end
        
        function waitSpacePress(obj)
            fprintf('press space to start.\n');
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

