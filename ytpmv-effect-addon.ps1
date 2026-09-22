# YTP+++ PowerShell plugin: Ytpmv Effect Addon
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Ytpmv Effect Addon'
        description = 'Ytpmv Effect Addon YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = '''Ytpmv Effect Addon'''
                type = 'label'
            },
            @{
                name = 'Description'
                value = '''Ytpmv Effect Addon YTP+++ plugin.'''
                type = 'label'
            },
            @{
                name = 'Chance Roll'
                value = '100'
                type = 'number'
                tooltip = 'Chance that this addon processes the clip.'
            },
            @{
                name = 'Amount'
                value = '10'
                type = 'number'
                tooltip = 'Pixel displacement and chromatic offset amount.'
            },
            @{
                name = 'Speed'
                value = '1.25'
                type = 'float'
                tooltip = 'Visual movement and audio tempo multiplier.'
            },
            @{
                name = 'Beat Frames'
                value = '8'
                type = 'number'
                tooltip = 'Frame cadence for YTPMV stutter selection.'
            },
            @{
                name = 'Frame Reduction'
                value = '30'
                type = 'number'
                tooltip = 'Output frame rate after stutter processing.'
            },
            @{
                name = 'Use Overlay Library'
                value = '1'
                type = 'bool'
                tooltip = 'Blend one random YTPMV overlay image if available.'
            },
            @{
                name = 'Use Audio Library'
                value = '1'
                type = 'bool'
                tooltip = 'Mix one random YTPMV audio hit/loop if available.'
            },
            @{
                name = 'YTPMV Overlay Images'
                value = ''''''
                type = 'image'
                tooltip = 'PNG/JPG masks, captions, sprites and YTPMV visual layers.'
            },
            @{
                name = 'YTPMV Audio Hits'
                value = ''''''
                type = 'audio'
                tooltip = 'Short musical hits, memes, stabs and loops for beat accents.'
            }
        )
    }
}

function StartGeneration {
    param($options, $pluginSettings, $functions)
    return $true
}

function PostCommand {
    param($commandIndex, $outputResult, $errorResult, $options, $pluginSettings, $functions)
}

function StopGeneration {
    param($options, $pluginSettings, $functions)
    return $true
}
