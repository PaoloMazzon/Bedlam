import shutil

if __name__ == "__main__":
    names = [[1, 1, 1, 0, 0, 1, 1],
             [1, 1, 0, 0, 0, 0, 1],
             [1, 1, 1, 1, 1, 1, 1],
             [0, 1, 0, 0, 1, 1, 1],
             [0, 1, 0, 0, 0, 0, 1],
             [1, 1, 1, 0, 1, 1, 1],
             [0, 1, 1, 1, 0, 1, 1]]
    letters = ["A", "B", "C", "D", "E", "F", "G"]

    for y in range(7):
        for x in range(7):
            if names[y][x] == 1:
                name = "Map_" + letters[x] + str(y + 1) + ".tmj"
                print(name)
                shutil.copyfile("Forest_B2.tmj", name)