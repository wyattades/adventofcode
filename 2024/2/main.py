class Utils:
    @staticmethod
    def as_lines(raw_input):
        return raw_input.strip().split("\n")

    @staticmethod
    def as_numbers_lists(raw_input):
        return [list(map(int, line.split())) for line in Utils.as_lines(raw_input)]


def sign(num):
    return 1 if num > 0 else -1 if num < 0 else 0


def is_safe(level):
    if len(level) < 2:
        raise Exception("level must have at least two elements")

    sign_0 = sign(level[1] - level[0])

    for i in range(0, len(level) - 1):
        delta = level[i + 1] - level[i]
        abs_delta = abs(delta)

        # b/c the level differ by at least one and at most three
        if abs_delta < 1 or abs_delta > 3:
            return False

        # b/c it's not strictly increasing or decreasing
        if sign(delta) != sign_0:
            return False

    return True


def level_1(raw_input):
    levels = Utils.as_numbers_lists(raw_input)

    answer = sum(1 for level in levels if is_safe(level))

    return answer


def is_safe_with_one_removed(level):
    if is_safe(level):
        return True

    for i in range(len(level)):
        if is_safe(level[:i] + level[i + 1 :]):
            return True

    return False


# same as level_1, but now it is safe if removing any one level
# makes it safe.
def level_2(raw_input):
    levels = Utils.as_numbers_lists(raw_input)

    answer = sum(1 for level in levels if is_safe_with_one_removed(level))

    return answer
