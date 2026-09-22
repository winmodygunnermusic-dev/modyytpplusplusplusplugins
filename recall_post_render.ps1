# YTP+++ PowerShell plugin: Recall Post Render
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Recall Post Render'
        description = 'Replays brief moments from the finished video with rewind, freeze, and recall-style timing.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Recall Post Render'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Replays brief moments from the finished video with rewind, freeze, and recall-style timing.'
                type = 'label'
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
