# YTP+++ PowerShell plugin: Repeatedly Slow Down
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Repeatedly Slow Down'
        description = 'Repeatedly slows the video down through multiple passes.'
        settings = @(
            @{
                name = 'Display Name'
                value = '''Repeatedly Slow Down'''
                type = 'label'
            },
            @{
                name = 'Description'
                value = '''Repeatedly slows the video down through multiple passes.'''
                type = 'label'
            },
            @{
                name = 'Slowdown Passes'
                value = '3'
                type = 'int'
                tooltip = 'Number of times the slowdown is applied.'
            },
            @{
                name = 'Slowdown Factor'
                value = '0.75'
                type = 'float'
                tooltip = 'Playback speed used on every pass. 0.75 = 25% slower.'
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
