function defaults = getPipelineDefaults(signal, type)
% Returns the defaults for a given step in the standard level 2 pipeline
%
% Parameters:
%     signal       a structure compatible with EEGLAB EEG structure
%                   (must have .data and .srate fields
%     type         a string indicating type of defaults to return:
%                  boundary, resample, detrend, globaltrend, linenoise
%                  reference
%
% Output:
%     defaults     a structure with the parameters for the default types
%                  in the form of a structure that has fields
%                     value: default value
%                     classes:   classes that the parameter belongs to
%                     attributes:  attributes of the parameter
%                     description: description of parameter
%
nyquist = round(signal.srate/2);
topMultiple = floor(nyquist/60);
lineFrequencies = (1:topMultiple)*60;
switch lower(type)
    case 'boundary'
        defaults = struct('ignoreBoundaryEvents', ...
            getRules(false, {'logical'}, {}, ...
            ['If true and EEG has boundary events, some EEGLAB ' ...
            ' functions such as resample, respect boundaries, ' ...
            'leading to spurious discontinuities.']));
    case 'resample'
        defaults = struct( ...
            'resampleOff', ...
            getRules(true, {'logical'}, {}, ...
            'If true, resampling is not used.'), ...
            'resampleFrequency', ...
            getRules(512, {'numeric'}, {'scalar', 'positive'}, ...
            ['Frequency to resample at. If signal already has a ' ...
            'lower sampling rate, no resampling is done.']), ...
            'lowPassFrequency', ...
            getRules(0, {'numeric'}, {'scalar', 'nonnegative'}, ...
            ['Frequency to low pass or 0 if not performed. '...
            'The purpose of this low pass is to remove resampling ' ...
            'artifacts.']));
    case 'globaltrend'
        defaults = struct( ...
            'globalTrendChannels', ...
            getRules(1:size(signal.data, 1), {'numeric'}, ...
            {'row', 'positive', 'integer', '<=', size(signal.data, 1)}, ...
            'Vector of channel numbers of the channels for global detrending.'), ...
            'doGlobal', ...
            getRules(false, {'logical'}, {}, ...
            'If true, do a global detrending operation at before other processing.'), ...
            'doLocal', ...
            getRules(true, {'logical'}, {}, ...
            'If true, do a local linear trend before the global.'), ...
            'localCutoff', ...
            getRules(1/200, {'numeric'}, ...
            {'positive', 'scalar', '<', signal.srate/2}, ...
            'Frequency cutoff for long term local detrending.'), ...
            'localStepSize', ...
            getRules(40,  ...
            {'numeric'}, {'positive', 'scalar'}, ...
            'Seconds for detrend window slide.'));
    case 'detrend'
        defaults = struct( ...
            'detrendChannels', ...
            getRules(1:size(signal.data, 1), {'numeric'}, ...
            {'row', 'positive', 'integer', '<=', size(signal.data, 1)}, ...
            'Vector of channel numbers of the channels to detrend.'), ...
            'detrendType', ...
            getRules('high pass', {'char'}, {}, ...
            ['One of {''high pass'', ''linear'', ''none''}' ...
            ' indicating detrending type.']), ...
            'detrendCutoff', ...
            getRules(1, {'numeric'}, ...
            {'positive', 'scalar', '<', signal.srate/2}, ...
            'Frequency cutoff for detrending or high pass filtering.'), ...
            'detrendStepSize', ...
            getRules(0.02,  ...
            {'numeric'}, {'positive', 'scalar'}, ...
            'Seconds for detrend window slide.')  ...
            );
    case 'linenoise'
        defaults = struct( ...
            'lineNoiseChannels', ...
            getRules(1:size(signal.data, 1), {'numeric'}, ...
            {'row', 'positive', 'integer', '<=', size(signal.data, 1)}, ...
            'Vector of channel numbers of the channels to remove line noise from.'), ...
            'Fs', ...
            getRules(signal.srate, {'numeric'}, ...
            {'positive', 'scalar'}, ...
            'Sampling rate of the signal in Hz.'), ...
            'lineFrequencies', ...
            getRules(lineFrequencies, {'numeric'}, ...
            {'row', 'positive'}, ...
            'Vector of frequencies in Hz of the line noise peaks to remove.'), ...
            'p', ...
            getRules(0.01,  ...
            {'numeric'}, {'positive', 'scalar', '<', 1}, ...
            'Significance cutoff level for removing a spectral peak.'),  ...
            'fScanBandWidth', ...
            getRules(2,  ...
            {'numeric'}, {'positive', 'scalar'}, ...
            ['Half of the width of the frequency band centered ' ...
            'on each line frequency.']),  ...
            'taperBandWidth', ...
            getRules(2,  ...
            {'numeric'}, {'positive', 'scalar'}, ...
            'Bandwidth in Hz for the tapers.'),  ...
            'taperWindowSize', ...
            getRules(4,  ...
            {'numeric'}, {'positive', 'scalar'}, ...
            'Taper sliding window length in seconds.'),  ...
            'taperWindowStep', ...
            getRules(1,  ...
            {'numeric'}, {'positive', 'scalar'}, ...
            'Taper sliding window step size in seconds. '),  ...
            'tau', ...
            getRules(100,  ...
            {'numeric'}, {'positive', 'scalar'}, ...
            'Window overlap smoothing factor.'),  ...
            'pad', ...
            getRules(0,  ...
            {'numeric'}, {'integer', 'scalar'}, ...
            ['Padding factor for FFTs (-1= no padding, 0 = pad ' ...
            'to next power of 2, 1 = pad to power of two after, etc.).']),  ...
            'fPassBand', ...
            getRules([0 signal.srate/2], {'numeric'}, ...
            {'nonnegative', 'row', 'size', [1, 2], '<=', signal.srate/2}, ...
            'Frequency band used (default [0, Fs/2])'),  ...
            'maximumIterations', ...
            getRules(10,  ...
            {'numeric'}, {'positive', 'scalar'}, ...
            ['Maximum number of times the cleaning process ' ...
            'applied to remove line noise.']) ...
            );
    case 'reference'
        defaults = struct( ...
            'srate', ...
            getRules(signal.srate, {'numeric'}, ...
            {'positive', 'scalar'}, ...
            'Sampling rate of the signal in Hz.'), ...
            'samples', ...
            getRules(size(signal.data, 2), {'numeric'}, ...
            {'positive', 'scalar'}, ...
            'Number of frames to use for computation.'), ...
            'robustDeviationThreshold', ...
            getRules(5, {'numeric'}, ...
            {'positive', 'scalar'}, ...
            'Z-score cutoff for robust channel deviation.'), ...
            'highFrequencyNoiseThreshold', ...
            getRules(5, {'numeric'}, ...
            {'positive', 'scalar'}, ...
            'Z-score cutoff for SNR (signal above 50 Hz).'), ...
            'correlationWindowSeconds', ...
            getRules(1, {'numeric'}, ...
            {'positive', 'scalar'}, ...
            'Correlation window size in seconds.'), ...
            'correlationThreshold', ...
            getRules(0.4, {'numeric'}, ...
            {'positive', 'scalar', '<=', 1}, ...
            'Max correlation threshold for channel being bad in a window.'), ...
            'badTimeThreshold', ...
            getRules(0.01, {'numeric'}, ...
            {'positive', 'scalar'}, ...
            ['Threshold fraction of bad correlation windows '...
            'for designating channel to be bad.']), ...
            'ransacOff', ...
            getRules(false, {'logical'}, {}, ...
            ['If true, RANSAC is not used for bad channel ' ...
            '(useful for small headsets).']), ...
            'ransacSampleSize', ...
            getRules(50, {'numeric'}, ...
            {'positive', 'scalar', 'integer'}, ...
            'Number of sample matrices for computing ransac.'), ...
            'ransacChannelFraction', ...
            getRules(0.25, {'numeric'}, ...
            {'positive', 'scalar', '<=', 1}, ...
            'Fraction of evaluation channels RANSAC uses to predict a channel.'), ...
            'ransacCorrelationThreshold', ...
            getRules(0.75, {'numeric'}, ...
            {'positive', 'scalar', '<=', 1}, ...
            'Cutoff correlation for unpredictability by neighbors.'), ...
            'ransacUnbrokenTime', ...
            getRules(0.4, {'numeric'}, ...
            {'positive', 'scalar', '<=', 1}, ...
            'Cutoff fraction of time channel can have poor ransac predictability.'), ...
            'ransacWindowSeconds', ...
            getRules(5, {'numeric'}, ...
            {'positive', 'scalar'}, ...
            'Size of windows in seconds over which to compute RANSAC predictions.'), ...
            'referenceType', ...
            getRules('robust', {'char'}, {}, ...
            ['Type of reference: robust (default), average, specific, or none' ...
            'None: no interpolation is performed.']), ...
            'interpolationOrder', ...
            getRules('post-reference', {'char'}, {}, ...
            ['post-reference: bad channels are detected again and interpolated after referencing. ' ...
            'pre-reference: bad channels detected before referencing and interpolated. ' ...
            'none: no interpolation is performed.']), ...
            'meanEstimateType', ...
            getRules('median', {'char'}, {}, ...
            ['Method for initial mean estimate in robust reference: ' ...
            'median (default), huber, mean, or none']), ...
            'referenceChannels', ...
            getRules(1:size(signal.data, 1), {'numeric'}, ...
            {'row', 'positive', 'integer', '<=', size(signal.data, 1)}, ...
            'Vector of channel numbers of the channels used for reference.'), ...
            'evaluationChannels', ...
            getRules(1:size(signal.data, 1), {'numeric'}, ...
            {'row', 'positive', 'integer', '<=', size(signal.data, 1)}, ...
            'Vector of channel numbers of the channels to test for noisiness.'), ...
            'rereferencedChannels', ...
            getRules(1:size(signal.data, 1), {'numeric'}, ...
            {'row', 'positive', 'integer', '<=', size(signal.data, 1)}, ...
            'Vector of channel numbers of the channels to rereference.'), ...
            'channelLocations', ...
            getRules(getFieldIfExists(signal, 'chanlocs'), {'struct'}, ...
            {'nonempty'}, ...
            'Structure of channel locations.'), ...
            'channelInformation', ...
            getRules(getFieldIfExists(signal, 'chaninfo'), ...
            {'struct'}, {}, ...
            'Channel information --- particularly nose direction.'), ...
            'maxReferenceIterations', ...
            getRules(4,  ...
            {'numeric'}, {'positive', 'scalar'}, ...
            'Maximum number of referencing interations'), ...
            'reportingLevel', ...
            getRules('verbose',  ...
            {'char'}, {}, ...
            'How much information to store about referencing') ...
            );
    case 'report'
        [~, EEGbase] = fileparts(signal.filename);
        defaults = struct( ...
           'reportMode', ...
            getRules('normal', {'char'}, {}, ...
            ['Indicates whether or how report should be generated ' ...
            'normal (default) means report generated after PREP, ' ...
            'skip means report not generated at all, ' ...
            'reportOnly means PREP is skipped and report generated']), ...
            'summaryFilePath', ...
            getRules(['.' filesep EEGbase 'Summary.html'], {'char'}, {}, ...
            'File name (including necessary path) for html summary file.'), ...
            'sessionFilePath', ...
            getRules(['.' filesep EEGbase 'Report.pdf'], {'char'}, {}, ...
            'File name (including necessary path) pdf detail report.'), ...
            'consoleFID', ...
            getRules(1, {'numeric'}, {'positive', 'integer'}, ...
            'Open file desriptor for displaying report messages.'), ...
            'publishOn', ...
            getRules(true, {'logical'}, {}, ...
            'If true, use MATLAB publish to publish the results.') ...
            );
    case 'postprocess'
        defaults = struct(...
            'keepFiltered', ...
            getRules(false, {'logical'}, {}, ...
            'If true, keep the channels filtered'), ...
            'removeInterpolatedChannels', ...
            getRules(false, {'logical'}, {}, ...
            'If true, removes bad interpolated channels'), ...
            'cleanupReference', ...
            getRules(false, {'logical'}, {}, ...
            ['If true, removes many fields in .etc.noiseDetection.reference '...
            'resulting in smaller dataset. ' ...
            'Report cannot be generated in this case']));
    otherwise
end
end

function s = getRules(value, classes, attributes, description)
% Construct the default structure
s = struct('value', [], 'classes', [], ...
    'attributes', [], 'description', []);
s.value = value;
s.classes = classes;
s.attributes = attributes;
s.description = description;
end