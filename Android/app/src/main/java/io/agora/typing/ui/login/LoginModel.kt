package io.agora.typing.ui.login

import io.agora.typing.base.Result
import io.agora.typing.server.Server
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*
import androidx.lifecycle.*
import io.agora.typing.base.LogLevel
import io.agora.typing.base.Logger
import io.agora.typing.server.WithErrorInfoError

@FlowPreview
@ExperimentalCoroutinesApi
class LoginModel : ViewModel() {

    var userName: String? = null
    var friendName: String? = null

    private val _snackBar = MutableLiveData<String?>()
    private var _spinner = MutableLiveData<Boolean>()
    private var _online = MutableLiveData<Boolean>()

    /**
     * Request a snackbar to display a string.
     */
    val snackbar: LiveData<String?>
        get() = _snackBar

    /**
     * Show a loading spinner if true
     */
    val spinner: LiveData<Boolean>
        get() = _spinner

    /**
     * notify login action result
     */
    val online: LiveData<Boolean>
        get() = _online

    /**
     * Called immediately after the UI shows the snackbar.
     */
    fun onSnackbarShown() {
        _snackBar.value = null
    }

    fun onClickLoginButton() {
        loginAction()
    }

    private fun loginAction() = launchDataLoad {
        login().collect {
            Logger.log("login success", LogLevel.Info)
            _snackBar.value = "Login Success!"
            _online.value = true
        }
    }

    private suspend fun login(): Flow<Result<Void>> {
        return withContext(Dispatchers.IO) {
            if (userName?.isEmpty() == true || friendName?.isEmpty() == true) {
                throw WithErrorInfoError("Input user's name or friend's name!")
            } else {
                Server.Instance.login(userName!!)
            }
        }
    }

    /**
     * Helper function to call a data load function with a loading spinner, errors will trigger a
     * snackbar.
     *
     * By marking `block` as `suspend` this creates a suspend lambda which can call suspend
     * functions.
     *
     * @param block lambda to actually load data. It is called in the viewModelScope. Before calling the
     *              lambda the loading spinner will display, after completion or error the loading
     *              spinner will stop
     */
    private fun launchDataLoad(block: suspend () -> Unit): Unit {
        viewModelScope.launch {
            try {
                _spinner.value = true
                block()
            } catch (error: WithErrorInfoError) {
                _snackBar.value = error.message
            } finally {
                _spinner.value = false
            }
        }
    }
}