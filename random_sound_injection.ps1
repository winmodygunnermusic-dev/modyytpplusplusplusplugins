# YTP+++ PowerShell plugin: Random Sound Injection
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Random Sound Injection'
        description = 'Randomly injects sounds from the SFX library into the video''s audio.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Random Sound Injection'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Randomly injects sounds from the SFX library into the video''s audio.'
                type = 'label'
            },
            @{
                name = 'Chance Roll'
                value = '100'
                type = 'int'
                tooltip = 'Percentage chance for the effect to activate.'
            },
            @{
                name = 'Maximum Sounds'
                value = '8'
                type = 'int'
                tooltip = 'Maximum number of random sounds injected.'
            },
            @{
                name = 'Minimum Delay'
                value = '1.0'
                type = 'float'
                tooltip = 'Minimum delay between injected sounds in seconds.'
            },
            @{
                name = 'Maximum Delay'
                value = '8.0'
                type = 'float'
                tooltip = 'Maximum delay between injected sounds in seconds.'
            },
            @{
                name = 'Volume'
                value = '1.0'
                type = 'float'
                tooltip = 'Volume multiplier for injected sounds.'
            },
            @{
                name = 'Random Pitch'
                value = '1'
                type = 'bool'
                tooltip = 'Randomly changes the pitch of injected sounds.'
            },
            @{
                name = 'Pitch Variation'
                value = '0.15'
                type = 'float'
                tooltip = 'Maximum pitch variation when Random Pitch is enabled.'
            },
            @{
                name = 'SFX'
                value = ''''''
                type = 'audio'
                tooltip = 'Sound effects that can be randomly injected.'
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
