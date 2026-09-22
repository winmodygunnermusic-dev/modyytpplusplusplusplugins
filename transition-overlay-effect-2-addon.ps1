# YTP+++ PowerShell plugin: Transition Overlay Effect 2 Addon
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Transition Overlay Effect 2 Addon'
        description = 'YTP-style NVG pixel effect with safe default parameters.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Transition Overlay Effect 2 Addon'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'YTP-style NVG pixel effect with safe default parameters.'
                type = 'label'
            },
            @{
                name = 'amount'
                value = 0.5
                type = 'number'
            },
            @{
                name = 'speed'
                value = 1.0
                type = 'number'
            },
            @{
                name = 'size'
                value = 0.2
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
