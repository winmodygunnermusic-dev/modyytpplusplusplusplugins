# YTP+++ PowerShell plugin: Explosion Spam
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Explosion Spam'
        description = 'Randomly spams explosion clips over the source video.'
        settings = @(
            @{
                name = 'Display Name'
                value = '''Explosion Spam'''
                type = 'label'
            },
            @{
                name = 'Description'
                value = '''Randomly spams explosion clips over the source video.'''
                type = 'label'
            },
            @{
                name = 'Explosion Count'
                value = '12'
                type = 'int'
                tooltip = 'Number of explosions to create.'
            },
            @{
                name = 'Explosion Scale'
                value = '45'
                type = 'int'
                tooltip = 'Explosion size as a percentage of the video height.'
            },
            @{
                name = 'Position Randomness'
                value = '100'
                type = 'int'
                tooltip = 'How randomly explosions are positioned.'
            },
            @{
                name = 'Timing Randomness'
                value = '100'
                type = 'int'
                tooltip = 'How randomly explosions are distributed through the video.'
            },
            @{
                name = 'Explosion Opacity'
                value = '100'
                type = 'int'
                tooltip = 'Opacity of the explosion overlays.'
            },
            @{
                name = 'Screen Shake'
                value = '1'
                type = 'bool'
                tooltip = 'Adds a brief camera-shake effect when explosions occur.'
            },
            @{
                name = 'Color Boost'
                value = '1'
                type = 'bool'
                tooltip = 'Boosts explosion brightness and saturation.'
            },
            @{
                name = 'Randomize Scale'
                value = '1'
                type = 'bool'
                tooltip = 'Give every explosion a different size.'
            },
            @{
                name = 'Overlap Explosions'
                value = '1'
                type = 'bool'
                tooltip = 'Allows several explosions to appear at the same time.'
            },
            @{
                name = 'Use Green Screen Key'
                value = '0'
                type = 'bool'
                tooltip = 'Enable this if the explosion library uses green-screen footage.'
            },
            @{
                name = 'Green Screen Similarity'
                value = '0.30'
                type = 'float'
                tooltip = 'Strength of the green-screen key.'
            },
            @{
                name = 'Explosion Audio'
                value = '1'
                type = 'bool'
                tooltip = 'Keep explosion audio when the library clips contain audio.'
            },
            @{
                name = 'Audio Volume'
                value = '100'
                type = 'int'
                tooltip = 'Explosion audio volume percentage.'
            },
            @{
                name = 'Explosions'
                value = ''''''
                type = 'video'
                tooltip = 'Explosion overlay video clips.'
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
