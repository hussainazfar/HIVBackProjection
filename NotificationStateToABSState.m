function [ABSState]=NotificationStateToABSState(NotificationState)
% 
% State	Notification	ABS
% NSW	2	1
% VIC	7	2
% QLD	4	3
% SA	5	4
% WA	8	5
% TAS	6	6
% NT	3	7
% ACT	1	8

StateMatrix=[8 1 7 3 4 6 2 5];

ABSState=StateMatrix(NotificationState);

% ABSState
% 
% if NotificationState==	2	
%     ABSState=	1	;	
% end
% if NotificationState==	7	
%     ABSState=	2	;	
% end
% if NotificationState==	4	
%     ABSState=	3	;	
% end
% if NotificationState==	5	
%     ABSState=	4	;	
% end
% if NotificationState==	8	
%     ABSState=	5	;	
% end
% if NotificationState==	6	
%     ABSState=	6	;	
% end
% if NotificationState==	3	
%     ABSState=	7	;	
% end
% if NotificationState==	1	
%     ABSState=	8	;	
% end
% 
% ABSState

end
