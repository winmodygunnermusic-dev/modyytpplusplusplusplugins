# YTP+++ PowerShell plugin: Double Twentieths
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Double Twentieths'
        description = 'Duplicates tiny 1/20-second sections of the video to create a rapid doubled micro-stutter effect.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Double Twentieths'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Duplicates tiny 1/20-second sections of the video to create a rapid doubled micro-stutter effect.'
                type = 'label'
            },
            @{
                name = 'Repeat Count'
                value = '2'
                type = 'int'
                tooltip = 'How many times each selected twentieth-second section is repeated.'
            },
            @{
                name = 'Twentieths'
                value = '12'
                type = 'int'
                tooltip = 'Number of 1/20-second sections to process.'
            },
            @{
                name = 'Random Position'
                value = '1'
                type = 'bool'
                tooltip = 'Randomly selects the locations where the micro-stutters occur.'
            },
            @{
                name = 'Strength'
                value = '50'
                type = 'int'
                tooltip = 'Controls how much of the source video is replaced by the repeated sections.'
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
