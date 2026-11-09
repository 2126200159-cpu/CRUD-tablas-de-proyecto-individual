package edu.utj.evnd.poo.bibliotecaproyec;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;

/**
 * Aplicación JavaFX del sistema de biblioteca. Carga el menú principal y
 * aplica una hoja de estilos común a todas las vistas.
 *
 * @author Joshua Odin Montoya Flores
 */
public class App extends Application {

    private static Scene scene;

    @Override
    public void start(Stage stage) throws IOException {
        scene = new Scene(loadFXML("menu"), 1020, 720);
        URL css = App.class.getResource("/styles/app.css");
        if (css != null) {
            scene.getStylesheets().add(css.toExternalForm());
        }
        stage.setTitle("Sistema de Biblioteca");
        stage.setMinWidth(900);
        stage.setMinHeight(640);
        stage.setScene(scene);
        stage.show();
    }

    /**
     * Cambia la vista raíz de la ventana.
     *
     * @param fxml nombre del archivo FXML (con o sin extensión)
     * @throws IOException si no se encuentra o no se puede cargar
     */
    public static void setRoot(String fxml) throws IOException {
        scene.setRoot(loadFXML(fxml));
    }

    /**
     * Carga un archivo FXML desde los recursos del proyecto.
     *
     * @param fxml nombre del archivo FXML (con o sin extensión)
     * @return nodo raíz de la vista
     * @throws IOException si no se encuentra o no se puede cargar
     */
    public static Parent loadFXML(String fxml) throws IOException {
        String fileName = fxml.endsWith(".fxml") ? fxml : fxml + ".fxml";
        FXMLLoader fxmlLoader = new FXMLLoader();

        String[] rutas = {
            "/" + fileName,
            "/edu/utj/evnd/poo/bibliotecaproyec/" + fileName,
            fileName
        };

        InputStream is = null;
        for (String ruta : rutas) {
            is = App.class.getResourceAsStream(ruta);
            if (is != null) {
                fxmlLoader.setLocation(App.class.getResource(ruta));
                break;
            }
        }
        if (is == null) {
            throw new IOException("El archivo " + fileName + " no está en src/main/resources.");
        }
        return fxmlLoader.load(is);
    }

    public static void main(String[] args) {
        launch();
    }
}
