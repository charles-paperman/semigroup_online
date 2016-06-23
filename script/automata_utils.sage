def random_automaton(size, alphabet):
    states = range(size)
    transition = {}
    for x in states:
        for a in alphabet:
            transition[(x,a)] = sample(states,1)
    return Automaton(transition,sample(states,1),sample(states,1),states,alphabet)

