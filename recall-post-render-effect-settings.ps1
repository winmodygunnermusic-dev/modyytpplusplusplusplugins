# YTP+++ PowerShell plugin: Recall Post Render Effect Settings
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Recall Post Render Effect Settings'
        description = 'YTP-style NVG pixel effect with safe default parameters.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Recall Post Render Effect Settings'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'YTP-style NVG pixel effect with safe default parameters.'
                type = 'label'
            },
            @{
                name = 'recallTime'
                value = 5
                type = 'number'
            },
            @{
                name = 'clipCount'
                value = 20
                type = 'number'
            },
            @{
                name = 'delay'
                value = 0
                type = 'number'
            },
            @{
                name = 'creationLength'
                value = 5
                type = 'number'
            }
        )
    }
}

function run {
    param($state)

    if ($null -eq $state) {
        return $null
    }

    return @($state.r, $state.g, $state.b)
}
