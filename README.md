# Description

Container template for OPE project

## User Guide:

You will also need docker **and** an account with docker, more instructions on downloading docker are here, if you don't yet have it: https://docs.docker.com/desktop/

Building a new container image:
1. Using quay.io, create a new repository, name it and make sure it's set to public
2. Back in the terminal, cd into your book's container directory
3. Run the ope new_container command with the name of your container: ```ope new_container <container-name>```
4. To add packages to your new container, open the python_pkgs file and add any new packages you may need in the same way you would with a requirements.txt file
5. Then open the **ope_book_user file**, and replace the name to your quay.io username, which is everything before the slash in the quay.io repository you created
6. Now open the **ope_container_name** file, replace the word base with the name of your repository, which is everything after the slash
7. Then open the **customization_name**, and replace the contents with the a name for your image
8. Now run: ```make build``` to create the image, this step can often take a couple minutes
9. You can see the image by running the ```docker images``` command
10. To run it locally, run the ```make run-beta``` command
11. This will start up a container and provide a link, so you can see it on your browser, so, you can copy and paste the link and the end of the terminal into your browser and view your container
12. Open a terminal on the jupyter notebook on the page from the link
13. To check if the packages you wanted are in the container, ```mamba list | grep "package-you-wanted-installed"``` on the terminal and your package should print
14. For examples, you can run ```git clone https://github.com/OPEFFORT/OPE-Testing.git``` and check out some templates, graphs, animations, videos, and interactive media that are possible with the container image you created


RISE Presentations:

RISE is a package that allows for Jupyter notebooks to be displayed as presentations, a useful feature for professors who may want to present textbook contents. To use RISE
1. Click on cell, and in the top right, use the property inspector button
2. Select what kind of slide it is
3. Once you've selected slide types, your container image can be rendered as a presentation, using the slides icon on the top right corner, now you can click through and see your slide show!

Publishing the container image:
1. Cd into your container directory and run ```make push```
2. In quay.io, go into the repository tags
2. Your quay.io repository should be populated
3. To customize your container with your new environement variables and use ```make customize```, open up the **customize_from** file
4. In quay.io, on the tag page, click the fetch tag icon, which is inbetween the settings gear icon and the manifest column
5. The fetch tag pop up will appear on your screen, and under image format, select Docker Pull
6. When the command is generated, copy everything after docker pull, but **do not** copy the docker pull, just the link
7. Add the link to the **customize_from** file (you can add it under the previous information)
8. To customize the image further, you can use and update the **customize_from/name/gid/group/uid** files, to update things like group_id, user_id
9. Change the **customize_name** file with a new name, to replace the old name and show that it's a customized image
10. Then in the terminal, run ```make customize```
11. Run ```docker images``` to see if your customized image has built
12. If it has built, run ```make run-cust```
13. Copy the link at the bottom of the terminal into your browser
14. You have created your customized container image


