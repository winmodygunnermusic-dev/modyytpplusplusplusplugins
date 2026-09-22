# YTP+++ PowerShell plugin: Sentence Mixing
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Sentence Mixing'
        description = 'Cuts, rearranges, reverses and stutters parts of the source audio for chaotic YTP-style sentence mixing.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Sentence Mixing'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Cuts, rearranges, reverses and stutters parts of the source audio for chaotic YTP-style sentence mixing.'
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
