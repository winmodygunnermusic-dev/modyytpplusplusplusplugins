# YTP+++ PowerShell plugin: Recall Post Render
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Recall Post Render'
        description = 'Replays brief moments from the finished video with rewind, freeze, and recall-style timing.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'effectName'
                type = 'label'
            },
            @{
                name = 'Description'
                value = '"Replays brief moments from the finished video with rewind'
                type = 'label'
            },
            @{
                name = 'Addon Type'
                value = 'postrendereffect'
                type = 'label'
            },
            @{
                name = 'Recall Strength'
                value = '50'
                type = 'int'
                tooltip = 'Controls how noticeable the recall effect is.'
            },
            @{
                name = 'Recall Count'
                value = '3'
                type = 'int'
                tooltip = 'Number of recall/replay sections to create.'
            },
            @{
                name = 'Freeze Frames'
                value = '1'
                type = 'bool'
                tooltip = 'Adds short freeze-frame moments.'
            },
            @{
                name = 'Reverse Recall'
                value = '1'
                type = 'bool'
                tooltip = 'Adds short reversed sections before replaying them.'
            },
            @{
                name = 'Audio Recall'
                value = '1'
                type = 'bool'
                tooltip = 'Preserves audio while creating the recall sections.'
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
