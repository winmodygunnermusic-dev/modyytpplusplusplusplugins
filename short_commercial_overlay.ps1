# YTP+++ PowerShell plugin: Short Commercial Overlay
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Short Commercial Overlay'
        description = 'Short Commercial Overlay YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = '''Short Commercial Overlay'''
                type = 'label'
            },
            @{
                name = 'Description'
                value = '''Short Commercial Overlay YTP+++ plugin.'''
                type = 'label'
            },
            @{
                name = 'Chance'
                value = '35'
                type = 'number'
            },
            @{
                name = 'Max Duration'
                value = '4'
                type = 'number'
            },
            @{
                name = 'Commercials'
                value = ''''''
                type = 'video'
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
