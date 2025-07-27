import platform

from trame.app import get_server
from trame.decorators import TrameApp, change
from trame.ui.vuetify3 import SinglePageLayout
from trame.widgets import html
from trame.widgets import vtk as vtk_widgets
from trame.widgets import vuetify3 as vuetify
from vtkmodules.vtkFiltersSources import vtkConeSource
from vtkmodules.vtkRenderingCore import (
    vtkActor,
    vtkPolyDataMapper,
    vtkRenderer,
    vtkRenderWindow,
    vtkRenderWindowInteractor,
)

# VTK factory initialization
from vtkmodules.vtkInteractionStyle import vtkInteractorStyleSwitch  # noqa
import vtkmodules.vtkRenderingOpenGL2  # noqa


PLATFORM_INFO = ", ".join(
    [
        platform.platform(),
        platform.python_compiler(),
        platform.python_implementation(),
        platform.python_version(),
        platform.python_build()[1],
    ]
)
print("PLATFORM_INFO", PLATFORM_INFO)


@TrameApp()
class MyTrameApp:
    def __init__(self, server_or_name=None):
        self.server = get_server(server_or_name, client_type="vue3")
        self.vtk_render_window, self.vtk_cone_source = self.setup_vtk()
        self.ui = self.generate_ui()

    @property
    def controller(self):
        return self.server.controller

    @property
    def state(self):
        return self.server.state

    @change("resolution")
    def on_resolution_change(self, resolution, **kwargs):
        self.vtk_cone_source.SetResolution(resolution)
        self.controller.view_update()

    @property
    def resolution(self):
        return self.state.resolution

    @resolution.setter
    def resolution(self, value):
        with self.state:
            self.state.resolution = value

    def reset_resolution(self):
        self.resolution = 6

    def setup_vtk(self):
        renderer = vtkRenderer()
        render_window = vtkRenderWindow()
        render_window.AddRenderer(renderer)
        render_window.OffScreenRenderingOn()

        render_window_interactor = vtkRenderWindowInteractor()
        render_window_interactor.SetRenderWindow(render_window)
        render_window_interactor.GetInteractorStyle().SetCurrentStyleToTrackballCamera()

        cone_source = vtkConeSource()
        mapper = vtkPolyDataMapper()
        actor = vtkActor()
        mapper.SetInputConnection(cone_source.GetOutputPort())
        actor.SetMapper(mapper)
        renderer.AddActor(actor)
        renderer.ResetCamera()
        render_window.Render()

        return render_window, cone_source

    def generate_ui(self):
        with SinglePageLayout(self.server) as layout:
            layout.title.set_text("trame Demo")

            with layout.toolbar as toolbar:
                toolbar.dense = True

                html.Div(f"PLATFORM_INFO: {PLATFORM_INFO}", style="font-size: 12px")
                vuetify.VSpacer()
                vuetify.VSlider(
                    v_model=("resolution", 6),
                    min=3,
                    max=60,
                    step=1,
                    hide_details=True,
                    style="max-width: 300px;",
                )

                with vuetify.VBtn(icon=True, click=self.reset_resolution):
                    vuetify.VIcon("mdi-undo-variant")
                with vuetify.VBtn(icon=True, click=self.controller.view_reset_camera):
                    vuetify.VIcon("mdi-camera-retake")

            with layout.content as content:
                content.scrollable = False

                with vuetify.VContainer(fluid=True, classes="pa-0 fill-height"):
                    view = vtk_widgets.VtkRemoteView(self.vtk_render_window)
                    self.controller.view_update = view.update
                    self.controller.view_reset_camera = view.reset_camera

            return layout


def main(**kwargs):
    app = MyTrameApp()
    app.server.start(**kwargs)


if __name__ == "__main__":
    main()
