CivicConfig = {
    StartingMoney = {
        cash = 500,
        bank = 2500
    },
    DefaultJob = 'unemployed',
    MaxInventorySlots = 30,
    AutoSaveMinutes = 5,
    Jobs = {
        unemployed = {
            label = 'Unemployed',
            grades = { [0] = 'Resident' }
        },
        police = {
            label = 'Police',
            grades = { [0] = 'Cadet', [1] = 'Officer', [2] = 'Sergeant' }
        },
        mechanic = {
            label = 'Mechanic',
            grades = { [0] = 'Apprentice', [1] = 'Technician', [2] = 'Shop Lead' }
        },
        ambulance = {
            label = 'EMS',
            grades = { [0] = 'Trainee', [1] = 'Paramedic', [2] = 'Supervisor' }
        }
    }
}
