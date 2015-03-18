function [ABSState] = NotificationStateToABSState(NotificationState)
% 
% State	Notification	ABS
% NSW       2           1
% VIC       7           2
% QLD       4           3   
% SA        5           4
% WA        8           5
% TAS       6           6
% NT        3           7
% ACT       1           8

%StateMatrix = [8 1 7 3 4 6 2 5];

ABSState = [];

    for x = 1:length(NotificationState)
        if NotificationState ==	2	
            ABSState(x) =	1;	
        elseif NotificationState==	7	
            ABSState(x) =	2;	
        elseif NotificationState==	4	
            ABSState(x) =	3;	
        elseif NotificationState==	5	
            ABSState(x) =	4;	
        elseif NotificationState==	8	
            ABSState(x) =	5;	
        elseif NotificationState==	6	
            ABSState(x) =	6;	
        elseif NotificationState==	3	
            ABSState(x) =	7;	
        elseif NotificationState==	1	
            ABSState(x) =	8;	
        end
    end
end
