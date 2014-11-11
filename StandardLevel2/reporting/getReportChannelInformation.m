function [referenceLocations, referenceChannels] = ...
        getReportChannelInformation(channelLocations, results)
    % Extracts channel locations with bad channels labeled, info and 
    % reference channel list from report
    badCorrelationSymbol = 'c';
    badAmplitudeSymbol = '+';
    badNoiseSymbol = 'x';
    badRansacSymbol = '?';
    chanlocs = channelLocations;
    referenceChannels = results.referenceChannels;
    % Set the bad channel labels
    for j = results.badChannelsFromCorrelation
        chanlocs(j).labels = [chanlocs(j).labels badCorrelationSymbol];
    end
    for j = results.badChannelsFromDeviation
        chanlocs(j).labels = [chanlocs(j).labels badAmplitudeSymbol];
    end

    for j = results.badChannelsFromHFNoise
        chanlocs(j).labels = [chanlocs(j).labels badNoiseSymbol];
    end

    for j = results.badChannelsFromRansac
        chanlocs(j).labels = [chanlocs(j).labels badRansacSymbol];
    end

    good_chans = setdiff(referenceChannels, (results.noisyChannels)');
    for j = good_chans
        chanlocs(j).labels = ' ';
    end
    referenceLocations = chanlocs(referenceChannels);
end


