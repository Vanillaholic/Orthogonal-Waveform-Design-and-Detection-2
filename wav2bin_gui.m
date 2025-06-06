function wav2bin_gui
% WAV → 12-bit Offset Binary BIN  (Offset = 2047 fixed)
% Author: Xing Zihan  (2025-06-03)

%% ─── GUI 布局 ────────────────────────────────────────
h.fig = uifigure('Name','WAV → BIN Converter','Position',[100 100 620 460]);

% ① Load WAV
h.btnLoad = uibutton(h.fig,'Text','Load WAV', ...
    'Position',[20 420 90 30],'ButtonPushedFcn',@onLoadWav);
h.lblFile = uilabel(h.fig,'Text','No file loaded', ...
    'Position',[120 422 480 22],'FontAngle','italic');

% ② Scale
uilabel(h.fig,'Text','Scale (0-1):','Position',[20 370 80 22]);
h.edtScale = uieditfield(h.fig,'numeric','Value',0.05, ...
    'Limits',[0 1],'LowerLimitInclusive','on','Position',[110 370 80 22], ...
    'ValueChangedFcn',@updateHistogram);   % ←★ 新增回调

% ③ Save BIN
h.btnSave = uibutton(h.fig,'Text','Save BIN','Enable','off', ...
    'Position',[210 367 90 28],'ButtonPushedFcn',@onSaveBin);

% ④ Axes
h.ax1 = uiaxes(h.fig,'Position',[20 200 580 140]);
h.ax1.Title.String = 'Normalized waveform';
h.ax2 = uiaxes(h.fig,'Position',[20 30 580 140]);
h.ax2.Title.String = 'Quantized code histogram';
uilabel(h.fig,'Text','@Copyright Xing Zihan', ...
        'Position',[430 5 170 20], ...   % 右下角；根据窗口尺寸微调
        'FontAngle','italic');

% ── 数据容器 ──
handles = struct;
guidata(h.fig,handles);

%% ─── 回调 ────────────────────────────────────────────
    function onLoadWav(~,~)
        [fname,fpath] = uigetfile({'*.wav'},'Select WAV file');
        if isequal(fname,0), return; end

        [y,Fs] = audioread(fullfile(fpath,fname));
        y = y(:);
        handles.y_norm = y / max(abs(y));          % 存归一化波形
        guidata(h.fig,handles);

        % 绘原始波形
        cla(h.ax1); plot(h.ax1,handles.y_norm); grid(h.ax1,'on');
        h.ax1.Title.String = sprintf('Normalized waveform (%.2f s @ %.0f Hz)',...
                                     numel(y)/Fs, Fs);

        h.lblFile.Text = fullfile(fpath,fname);
        h.btnSave.Enable = 'on';

        % 初次绘制量化直方图
        updateHistogram();
    end

    function updateHistogram(~,~)   %#ok<*INUSD>
        handles = guidata(h.fig);
        if ~isfield(handles,'y_norm'), return; end   % 还没加载文件

        scale  = h.edtScale.Value;
        offset = 2047;

        handles.Yq = int16( round(handles.y_norm * 2048 * scale + offset) );
        guidata(h.fig,handles);

        cla(h.ax2);
        histogram(h.ax2,double(handles.Yq), ...
                  'BinLimits',[0 4095],'BinWidth',1,'FaceAlpha',0.7);
        grid(h.ax2,'on');
        h.ax2.Title.String = sprintf('Quantized codes (scale = %.3g)', scale);
    end

    function onSaveBin(~,~)
        handles = guidata(h.fig);
        if ~isfield(handles,'Yq')
            uialert(h.fig,'No quantized data – load a WAV first.','Error');
            return;
        end

        [fnOut,fpOut] = uiputfile('*.bin','Save BIN as','converted.bin');
        if isequal(fnOut,0), return; end
        fid = fopen(fullfile(fpOut,fnOut),'wb');
        fwrite(fid,handles.Yq,'short');
        fclose(fid);

        uialert(h.fig,'BIN file saved successfully.','Done');
    end
end
