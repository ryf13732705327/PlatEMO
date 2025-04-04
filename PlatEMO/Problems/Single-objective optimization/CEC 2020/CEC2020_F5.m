classdef CEC2020_F5 < PROBLEM
% <2019> <single> <real>
% Hybrid function 1

%------------------------------- Reference --------------------------------
% C .T. Yue, K. V. Price, P. N. Suganthan, J. J. Liang, M. Z. Ali, B. Y.
% Qu, N. H. Awad, and P. P. Biswas. Problem definitions and evaluation
% criteria for the CEC 2020 special session and competition on single
% objective bound constrained numerical optimization. Zhengzhou University,
% China and Nanyang Technological University, Singapore, 2019.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2025 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    properties
        O;      % Optimal decision vector
        Mat;	% Rotation matrix
        S;      % Indices of variables in each subcomponent
    end
    methods
        %% Default settings of the problem
        function Setting(obj)
            CallStack = dbstack('-completenames');
            load(fullfile(fileparts(CallStack(1).file),'CEC2020.mat'),'Data');
            obj.O = Data{5}.o;
            obj.M = 1;
            if isempty(obj.D) || obj.D < 10
                obj.D   = 5;
                obj.Mat = Data{5}.M_5;
                obj.S   = Data{5}.S_5;
            elseif obj.D < 15
                obj.D   = 10;
                obj.Mat = Data{5}.M_10;
                obj.S   = Data{5}.S_10;
            elseif obj.D < 20
                obj.D   = 15;
                obj.Mat = Data{5}.M_15;
                obj.S   = Data{5}.S_15;
            else
                obj.D   = 20;
                obj.Mat = Data{5}.M_20;
                obj.S   = Data{5}.S_20;
            end
            p     = ceil([0.3 0.3 0.4]*obj.D);
            p(1)  = obj.D - sum(p(2:end));
            p     = [0,cumsum(p)];
            obj.S = arrayfun(@(i)obj.S(p(i)+1:p(i+1)),1:length(p)-1,'UniformOutput',false);
            obj.lower    = zeros(1,obj.D) - 100;
            obj.upper    = zeros(1,obj.D) + 100;
            obj.encoding = ones(1,obj.D);
        end
        %% Calculate objective values
        function PopObj = CalObj(obj,PopDec)
            Y = PopDec - repmat(obj.O(1:size(PopDec,2)),size(PopDec,1),1);
            Z = Y*obj.Mat';
            PopObj = 1700 + Schwefel(Z(:,obj.S{1})) + Rastrigin(Z(:,obj.S{2})) + Elliptic(Z(:,obj.S{3}));
        end
    end
end

function F = Schwefel(X)
	X         = 10*X + 4.2097e2;
    g         = X.*sin(sqrt(abs(X)));
    temp      = 500 - mod(X(X>500),500);
    g(X>500)  = temp.*sin(sqrt(abs(temp))) - (X(X>500)-500).^2/10000/size(X,2);
    temp      = mod(abs(X(X<-500)),500) - 500;
    g(X<-500) = temp.*sin(sqrt(abs(temp))) - (X(X<-500)-500)/10000/size(X,2);
    F         = 418.9829*size(X,2) - sum(g,2);
end

function F = Rastrigin(X)
    X = 0.0512*X;
    F = sum(X.^2-10*cos(2*pi*X)+10,2);
end

function F = Elliptic(X)
    F = sum((1e6).^(repmat(0:size(X,2)-1,size(X,1),1)/(size(X,2)-1+1e-6)).*X.^2,2);
end