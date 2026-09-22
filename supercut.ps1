# YTP+++ PowerShell plugin: Supercut
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Supercut'
        description = 'Rapidly cuts together many short sections of the source video.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Supercut'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Rapidly cuts together many short sections of the source video.'
                type = 'label'
            },
            @{
                name = 'Cut Count'
                value = '20'
                type = 'integer'
                tooltip = 'Number of clips used to build the supercut.'
            },
            @{
                name = 'Minimum Clip Duration'
                value = '0.15'
                type = 'decimal'
                tooltip = 'Minimum duration of each selected clip in seconds.'
            },
            @{
                name = 'Maximum Clip Duration'
                value = '0.60'
                type = 'decimal'
                tooltip = 'Maximum duration of each selected clip in seconds.'
            },
            @{
                name = 'Start Offset'
                value = '0'
                type = 'decimal'
                tooltip = 'Avoids selecting material before this many seconds.'
            },
            @{
                name = 'End Padding'
                value = '0.10'
                type = 'decimal'
                tooltip = 'Avoids selecting material this many seconds before the end.'
            },
            @{
                name = 'Randomness'
                value = '100'
                type = 'integer'
                tooltip = 'Higher values spread the cuts more randomly through the video.'
            },
            @{
                name = 'Keep Audio'
                value = '1'
                type = 'bool'
                tooltip = 'Keep and synchronize audio from every selected clip.'
            },
            @{
                name = 'Normalize Clips'
                value = '1'
                type = 'bool'
                tooltip = 'Normalize timestamps of every selected clip before concatenation.'
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
