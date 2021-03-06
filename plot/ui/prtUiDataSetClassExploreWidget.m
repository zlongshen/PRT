classdef prtUiDataSetClassExploreWidget < prtUiManagerPanel
    % ToDo:
    %   onClickCallback
    %   axesDeleteCallbacl
    %   Make the legened stay where we put it
    %   uicontext menu feature select







    properties
        plotManager
        
        titleStr = 'prtDataSetClass Explorer Widget';
        
        tabObjectConstructors = {@prtUiDataSetClassExploreWidgetTabSelectAxes @prtUiDataSetClassExploreWidgetTabPlotOptions @prtUiDataSetClassExploreWidgetTabClickDisplay};
        
        handles
        tabs
        
        madeThisWindow = false;
    end
    
    methods
        function self = prtUiDataSetClassExploreWidget(varargin)
            
            if mod(nargin,2)
                varargin = cat(2,{'plotManager'},varargin);
            end
            self = self@prtUiManagerPanel(varargin{:});
            
            if isempty(self.plotManager)
                error('prt:prtUiDataSetClassExploreWidget:noInput','plotManager must be specified');
            end
            
            init(self);
        end
        
        function create(self)
            
            navFigSize = [300 250];
            navFigPad = [18 54];
            
            plotAxesFigPos = get(self.plotManager.handles.figure,'position');
            
            oldUnits = get(self.plotManager.handles.axes,'units');
            set(self.plotManager.handles.axes,'Units','pixels');
            plotAxesOuterPos = get(self.plotManager.handles.axes,'outerposition');
            set(self.plotManager.handles.axes,'units',oldUnits);
            
            navFigPosTop = plotAxesFigPos(2)+plotAxesOuterPos(2)-1+plotAxesOuterPos(4) + navFigPad(2);
            navFigPosLeft = plotAxesFigPos(1)+plotAxesOuterPos(1)-1+plotAxesOuterPos(3) + navFigPad(1);
            
            % Make sure we aren't off the screen
            screenSize = get(0,'screensize');
            navFigPosTop = min([navFigPosTop, screenSize(4)-50]);
            navFigPosLeft = min([navFigPosLeft, screenSize(3)-navFigSize(2)-60]);
            
            navFigPos = cat(2,navFigPosLeft, navFigPosTop-navFigSize(2), navFigSize(1), navFigSize(2));

            self.handles.figure = figure('units','pixels',...
                'position', navFigPos,...
                'menubar','none',...
                'toolbar','none',...
                'numberTitle','off',...
                'Name',self.titleStr,...
                'Interruptible','off',...
                'BusyAction','cancel',...
                'DockControls','off',...
                'NextPlot','new');
            
            self.managedHandle = uipanel(self.handles.figure, ...
                'units','normalized',...
                'BorderType','none',...
                'Position',[0 0 1 1]);
            
            self.madeThisWindow = true;
            
            % Just in case anyone tries to plot in this window we will plot that inside
            % an invisible axes
            self.handles.invisibleAxes = axes('parent',self.handles.figure,...
                'units','pixels',...
                'position',[0 0  1 1],...
                'visible','off',...
                'handlevisibility','on');
        end
        
        function init(self)
            self.handles.tabGroup = prtUtilUitabgroup('parent',self.managedHandle);
            nTabs = length(self.tabObjectConstructors);
            self.handles.tabs = prtUtilPreAllocateHandles(nTabs,1);
            self.handles.tabPanels = prtUtilPreAllocateHandles(nTabs,1);
            for iTab = 1:nTabs
                self.handles.tabs(iTab) = prtUtilUitab(self.handles.tabGroup, 'title', 'Temp');
                self.handles.tabPanels(iTab) = uipanel('parent',self.handles.tabs(iTab));
                %uicontrol(self.handles.tabPanels(iTab),'style','pushbutton','string','hi');
                
                self.tabs{iTab} = self.tabObjectConstructors{iTab}('managedHandle',self.handles.tabPanels(iTab),'widget',self);
                set(self.handles.tabs(iTab), 'title', self.tabs{iTab}.titleStr);
            end
            
            %self.handles.listenerClose = addlistener(self.plotManager.handles.axes,'BeingDeleted',@(~,~)close(self.handles.figure));
            cDeleteFcn = get(self.plotManager.handles.axes,'DeleteFcn');
            if ~isempty(cDeleteFcn)
                warning('prtUiDataSetClassExploreWidget removed an existing axes DeleteFcn. This is a bug that will be removed in a future release');
            end
            set(self.plotManager.handles.axes,'DeleteFcn',@(~,~)self.onPlotAxesDelete())
            
        end
        function onPlotAxesDelete(self)
            try  %#ok<TRYNC>
                close(self.handles.figure);
            end
        end
        function close(self)
            try  %#ok<TRYNC>
                close(self.handles.figure);
            end
        end
    end
end
