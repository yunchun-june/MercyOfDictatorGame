classdef parser
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = parser()
        end
        
        function str = listToStr(obj, list)
            temp = size(list);
            thesize = temp(1);
            str = '';
            for i = 1:thesize
                str = strcat(str,num2str(list(i)),',');
            end
        end
        
        function condList = strToList(~, str)
            c = strsplit(str,',');
            temp = size(c);
            thesize = temp(2)-1;
            condList = zeros(thesize,1);
            for i = 1:thesize
                condList(i,1) = str2num(c{i});
            end
        end
        
%         myRes.youAreDictator = strcmp(rule,data.getDictator(trial));
%         myRes.keepMoney  = 5;
%         myRes.givenMoney = 5;
%         myRes.s1 = 4;
%         myRes.s2 = 4;
%         myRes.s3 = 4;
%         
%         %data handler respond package
%         myRes.allocateRT = 0;
%         myRes.s1RT = 0;
%         myRes.s2RT = 0;
%         myRes.s3RT = 0;
        
        function str = resToStr(obj, res)
            str = '';
            str = strcat(str,num2str(res.youAreDictator),',');
            str = strcat(str,num2str(res.keepMoney),',');
            str = strcat(str,num2str(res.givenMoney),',');
            str = strcat(str,num2str(res.s1),',');
            str = strcat(str,num2str(res.s2),',');
            str = strcat(str,num2str(res.s3),',');
            str = strcat(str,num2str(res.allocateRT),',');
            str = strcat(str,num2str(res.s1RT),',');
            str = strcat(str,num2str(res.s2RT),',');
            str = strcat(str,num2str(res.s3RT),',');
        end
        
        function res = strToRes(obj,str)
            c = strsplit(str,',');
            res.youAreDictator  = str2double(c{1});
            res.keepMoney       = str2double(c{2});
            res.givenMoney      = str2double(c{3});
            res.s1              = str2double(c{4});
            res.s2              = str2double(c{5});
            res.s3              = str2double(c{6});
            res.allocateRT      = str2double(c{7});
            res.s1RT            = str2double(c{8});
            res.s2RT            = str2double(c{9});
            res.s3RT            = str2double(c{10});
        end
        
       
    end
    
end

