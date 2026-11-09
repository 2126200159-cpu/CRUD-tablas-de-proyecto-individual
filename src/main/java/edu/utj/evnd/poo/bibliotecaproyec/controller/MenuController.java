package edu.utj.evnd.poo.bibliotecaproyec.controller;

import edu.utj.evnd.poo.bibliotecaproyec.App;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.net.URL;
import java.util.ResourceBundle;

import javafx.application.Platform;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.Parent;
import javafx.scene.control.Button;
import javafx.scene.layout.StackPane;

/**
 * Controlador del menú principal: permite navegar entre las vistas del
 * sistema (personas, libros, categorías y editoriales). Cada vista se carga
 * una sola vez y se reutiliza al cambiar de módulo.
 *
 * @author Joshua Odin Montoya Flores
 */
public class MenuController implements Initializable {

    @FXML private StackPane contenedor;
    @FXML private Button btnPersonas;
    @FXML private Button btnLibros;
    @FXML private Button btnCategorias;
    @FXML private Button btnEditoriales;

    private Parent vistaPersonas;
    private Parent vistaLibros;
    private Parent vistaCategorias;
    private Parent vistaEditoriales;

    @Override
    public void initialize(URL url, ResourceBundle rb) {
        try {
            vistaPersonas = App.loadFXML("persona");
            vistaLibros = App.loadFXML("libro");
            vistaCategorias = App.loadFXML("categoria");
            vistaEditoriales = App.loadFXML("editorial");
        } catch (IOException ex) {
            throw new UncheckedIOException(ex);
        }
        onPersonas();
    }

    @FXML
    private void onPersonas() {
        mostrar(vistaPersonas, btnPersonas);
    }

    @FXML
    private void onLibros() {
        mostrar(vistaLibros, btnLibros);
    }

    @FXML
    private void onCategorias() {
        mostrar(vistaCategorias, btnCategorias);
    }

    @FXML
    private void onEditoriales() {
        mostrar(vistaEditoriales, btnEditoriales);
    }

    @FXML
    private void onSalir() {
        Platform.exit();
    }

    private void mostrar(Parent vista, Button activo) {
        contenedor.getChildren().setAll(vista);
        for (Button b : new Button[]{btnPersonas, btnLibros, btnCategorias, btnEditoriales}) {
            b.getStyleClass().remove("activo");
        }
        activo.getStyleClass().add("activo");
    }
}
